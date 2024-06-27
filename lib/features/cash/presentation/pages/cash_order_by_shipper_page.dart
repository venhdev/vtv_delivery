import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/entities/cash_order_by_date_entity.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/entities/response/cash_order_response.dart';
import '../../domain/repository/cash_repository.dart';
import '../common/filter_cash_method.dart';
import '../components/custom_scroll_tab_view.dart';

class CashOrderByShipperPage extends StatefulWidget {
  const CashOrderByShipperPage({super.key});

  @override
  State<CashOrderByShipperPage> createState() => _CashOrderByShipperPageState();
}

class _CashOrderByShipperPageState extends State<CashOrderByShipperPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _shipperShippingListController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _shipperHoldingListController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
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
      items: <CashOrderByDateEntity>[],
      filterParams: FilterCashTransferParams(),
      futureCallback: () => sl<CashRepository>().historyByShipper(HistoryType.shipperShipping),
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
      ..setFirstRunCallback(() => _shipperHoldingListController.performFilter())
      ..init();

    _shipperHoldingListController = FilterListController(
      items: <CashOrderByDateEntity>[],
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
      items: <CashOrderByDateEntity>[],
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
                  isSlidable: false,
                ),
                //# shipper holding
                CustomScrollTabView.shipper(
                  futureListController: _shipperHoldingListController,
                  isSlidable: true,
                  onScanPressed: handleScanPressed,
                  onInsertPressed: handleInsertPressed,
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
          '${ConversionUtils.formatCurrency(getTotalMoneyByDate(date))} Tiền mặt sẽ được gửi lại cho "$warehouseUsername". Bạn chắc chắn chứ?',
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

  void handleInsertPressed(DateTime date) async {
    final warehouseUsername = await showDialogWithTextField(
      context: context,
      title: 'Mã kho',
      hintText: 'Nhập mã kho',
    ) as String?;
    if (warehouseUsername == null || warehouseUsername == '' || !mounted) return;

    await processTransfer(warehouseUsername, date);
  }

  void handleScanPressed(DateTime date) async {
    final warehouseUsername = await Navigator.of(context).pushNamed('/scan') as String?;
    if (warehouseUsername == null || !mounted) return;

    processTransfer(warehouseUsername, date);
  }
}
