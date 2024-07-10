import 'dart:convert';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../../delivery/domain/repository/delivery_repository.dart';
import '../../domain/entities/response/cash_order_by_date_resp.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/entities/response/cash_order_resp.dart';
import '../../domain/repository/cash_repository.dart';
import '../common/filter_cash_method.dart';
import '../components/cash_order_detail_dialog.dart';
import '../components/custom_scroll_tab_view.dart';

class CashOrderByShipperPage extends StatefulWidget {
  const CashOrderByShipperPage({super.key});

  @override
  State<CashOrderByShipperPage> createState() => _CashOrderByShipperPageState();
}

class _CashOrderByShipperPageState extends State<CashOrderByShipperPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FilterListController<CashOrderByDateResp, RespData<List<CashOrderByDateResp>>, FilterCashTransferParams>
      _shipperShippingListController;
  late FilterListController<CashOrderByDateResp, RespData<List<CashOrderByDateResp>>, FilterCashTransferParams>
      _shipperHoldingListController;
  late FilterListController<CashOrderByDateResp, RespData<List<CashOrderByDateResp>>, FilterCashTransferParams>
      _shipperTransferredListController;

  final _tabs = <Tab>[
    const Tab(text: 'Đang giao'),
    const Tab(text: 'Đang giữ tiền'),
    const Tab(text: 'Đã nộp kho'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _shipperShippingListController = FilterListController(
      items: <CashOrderByDateResp>[],
      filterParams: FilterCashTransferParams(),
      futureCallback: () => sl<CashRepository>().historyByShipper(HistoryType.shipperShipping),
      //> server fixed, client don't need to filter paid cash order
      // futureCallback: () async {
      //   final respEither = await sl<CashRepository>().historyByShipper(HistoryType.shipperShipping);
      //   return respEither.fold(
      //     (error) => dartz.Left(error),
      //     (ok) async {
      //       //? because server return all cash orders contain paid and unpaid, so we need to filter it
      //       //? if we don't filter, the paid cash order will be shown in the shipping list
      //       List<CashOrderByDateResp> rs = ok.data!;

      //       for (int i = 0; i < rs.length; i++) {
      //         final filterCashOrders = rs[i]
      //             .cashOrders
      //             // .where((cash) => (cash.status == Status.INACTIVE && cash.handlePayment == true))
      //             .where((cash) => (cash.status != Status.INACTIVE && cash.handlePayment == false))
      //             .toList();
      //         rs[i] = rs[i].copyWith(cashOrders: filterCashOrders);
      //       }

      //       return dartz.Right(SuccessResponse(data: rs));
      //     },
      //   );
      // },
      parse: (unparsedData, onParseError) {
        return unparsedData.fold(
          (error) {
            onParseError(errorMsg: error.message);
            return null;
          },
          (ok) {
            return ok.data!;
          },
        );
      },
    )
      ..setDebugLabel('shipperShipping')
      ..setFilterCallback(filterCashMethod)
      ..setFirstRunCallback(() => _shipperShippingListController.performFilter())
      ..init();

    _shipperHoldingListController = FilterListController(
      items: <CashOrderByDateResp>[],
      filterParams: FilterCashTransferParams(),
      futureCallback: () => sl<CashRepository>().historyByShipper(HistoryType.shipperHolding),
      parse: (unparsedData, onParseError) {
        return unparsedData.fold(
          (error) {
            onParseError(errorMsg: error.message);
            return null;
          },
          (ok) {
            return ok.data!;
          },
        );
      },
    )
      ..setDebugLabel('shipperHolding')
      ..setFilterCallback(filterCashMethod)
      ..setFirstRunCallback(() => _shipperHoldingListController.performFilter())
      ..init();

    _shipperTransferredListController = FilterListController(
      items: <CashOrderByDateResp>[],
      filterParams: FilterCashTransferParams(),
      futureCallback: () => sl<CashRepository>().historyByShipper(HistoryType.shipperTransferred),
      parse: (unparsedData, onParseError) {
        return unparsedData.fold(
          (error) {
            onParseError(errorMsg: error.message);
            return null;
          },
          (ok) {
            return ok.data!;
          },
        );
      },
    )
      ..setDebugLabel('shipperTransferred')
      ..setFilterCallback(filterCashMethod)
      ..setFirstRunCallback(() => _shipperTransferredListController.performFilter())
      ..init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          TabBar(
            padding: EdgeInsets.zero,
            controller: _tabController,
            tabs: _tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                //# shipper shipping
                CustomScrollTabView.shipper(
                  futureListController: _shipperShippingListController,
                  showAddress: true,
                  onCashItemPressed: (cashOrder) async => await showDialog(
                      context: context,
                      builder: (context) {
                        return CashOrderDetailDialog(cashOrderId: cashOrder.cashOrderId);
                      }),
                ),
                //# shipper holding
                CustomScrollTabView.shipper(
                  futureListController: _shipperHoldingListController,
                  isSlidable: true,
                  onScanPressed: handleTransferCashViaScanWarehouseQr,
                  onInsertPressed: handleTransferCashViaTypeUsername,
                ),
                //# shipper has transferred to warehouse
                CustomScrollTabView.shipper(
                  futureListController: _shipperTransferredListController,
                  isSlidable: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> getCashOrderIdsByDate(DateTime date) {
    return _shipperHoldingListController.items
        .where((element) => element.date == date)
        .expand((element) => element.cashOrders)
        .map((e) => e.cashOrderId)
        .toList();
  }

  int getTotalMoneyByDate(DateTime date) {
    return _shipperHoldingListController.items
        .where((element) => element.date == date)
        .expand((element) => element.cashOrders)
        .map((e) => e.money)
        .fold(0, (previousValue, element) => previousValue + element);
  }

  Future<void> processTransfer(String warehouseUsername, DateTime date) async {
    // show dialog to confirm transfer money to warehouse
    // if confirmed, call api then refresh list
    final isConfirm = await showDialogToConfirm<bool>(
      context: context,
      title: 'Gửi yêu cầu đối soát',
      content:
          'Gửi lại số tiền ${ConversionUtils.formatCurrency(getTotalMoneyByDate(date))} cho "$warehouseUsername". Bạn chắc chắn chứ?',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
    );

    if ((isConfirm ?? false) && mounted) {
      await showDialogToPerform<RespData<CashOrderResp>>(context,
          dataCallback: () async {
            return sl<CashRepository>().requestTransfersMoneyToWarehouseByShipper(
                TransferMoneyRequest(cashOrderIds: getCashOrderIdsByDate(date), waveHouseUsername: warehouseUsername));
          },
          onData: (data) {
            showToastResult(data as RespData, onSuccess: () {
              _shipperHoldingListController.refreshAndFilter();
              _shipperTransferredListController.refreshAndFilter();
            });
          },
          closeBy: (context, result) => Navigator.of(context).pop(result));
    }
  }

  // BUG: cannot use this function because the role is shipper
  void handleStoreOrdersByShipper(BuildContext _, DateTime date) async {
    final data = await Navigator.of(context).pushNamed('/scan') as String?;

    if (data == null || !mounted) return;
    String warehouseUsername;
    String warehouseWardCode;

    try {
      final parsed = jsonDecode(data) as Map<String, dynamic>;
      Logger().e(parsed);
      warehouseUsername = parsed['wU'];
      warehouseWardCode = parsed['wC'];
    } catch (e) {
      Logger().e(e);
      Fluttertoast.showToast(msg: 'Dữ liệu không hợp lệ');
      return;
    }
    Logger().e(warehouseUsername);
    Logger().e(warehouseWardCode);

    // show dialog to confirm store orders to warehouse
    final isConfirm = await showDialogToConfirm<bool>(
      context: context,
      title: 'Xác nhận lưu kho',
      content:
          'Tổng cộng ${_shipperShippingListController.items.length} đơn hàng trong ngày ${ConversionUtils.convertDateTimeToString(date)} sẽ được lưu vào kho "$warehouseUsername". Bạn chắc chắn chứ?',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
    );

    if ((isConfirm ?? false) && mounted) {
      List<String> transportIdsInDate = _shipperShippingListController.items
          .where((element) => element.date == date)
          .expand((element) => element.cashOrders)
          .map((e) => e.transportId)
          .toList();

      final listFailed = await showDialogToPerform<List<String>>(context,
          dataCallback: () async {
            final listIdsFailed = <String>[];
            await Future.wait(
                transportIdsInDate.map((transportId) => sl<DeliveryRepository>().updateStatusTransportByDeliver(
                      transportId,
                      OrderStatus.WAREHOUSE,
                      true,
                      warehouseWardCode,
                    ))).then(
              (result) {
                for (final resp in result) {
                  if (resp.isLeft()) {
                    listIdsFailed.add(transportIdsInDate[result.indexOf(resp)]);
                  }
                }
              },
            );

            return listIdsFailed;
          },
          closeBy: (context, result) => Navigator.of(context).pop(result));

      if ((listFailed?.isNotEmpty ?? false) && mounted) {
        await showDialogToAlert(
          context,
          title: const Text('Danh sách lưu kho không thành công'),
          children: [
            Text('Có ${listFailed!.length} đơn hàng không thể lưu vào kho được:'),
            for (final transportId in listFailed) Text(transportId),
          ],
        );
      } else if ((listFailed?.isEmpty ?? false) && mounted) {
        await showDialogToAlert(
          context,
          title: const Text('Lưu kho thành công'),
          children: [
            Text(
                'Tất cả ${_shipperShippingListController.items.length} đơn hàng trong ngày ${ConversionUtils.convertDateTimeToString(date)} đã được lưu vào kho "$warehouseUsername"'),
          ],
        );
      }
    }
  }

  void handleTransferCashViaTypeUsername(BuildContext _, DateTime date) async {
    final warehouseUsername = await showDialogWithTextField(
      context: context,
      title: 'Mã kho',
      hintText: 'Nhập mã kho',
    ) as String?;
    if (warehouseUsername == null || warehouseUsername == '' || !mounted) return;

    await processTransfer(warehouseUsername, date);
  }

  void handleTransferCashViaScanWarehouseQr(BuildContext _, DateTime date) async {
    final data = await Navigator.of(context).pushNamed('/scan') as String?;
    if (data == null || !mounted) return;
    Map<String, dynamic> parsed;

    try {
      parsed = jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      Fluttertoast.showToast(msg: 'QR không hợp lệ');
      return;
    }

    processTransfer(parsed['wU'], date);
  }
}
