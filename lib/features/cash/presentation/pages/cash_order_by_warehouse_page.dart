import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/entities/cash_order_by_date_entity.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/entities/response/cash_order_response.dart';
import '../../domain/repository/cash_repository.dart';
import '../common/filter_cash_method.dart';
import '../components/custom_scroll_tab_view.dart';

class CashOrderByWarehousePage extends StatefulWidget {
  const CashOrderByWarehousePage({super.key});

  @override
  State<CashOrderByWarehousePage> createState() => _CashOrderByWarehousePageState();
}

class _CashOrderByWarehousePageState extends State<CashOrderByWarehousePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _warehouseUnderConfirmationListController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _warehouseHoldingListController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _warehouseTransferredListController;

  final _tabs = <Tab>[
    const Tab(text: 'Chờ xác nhận'),
    const Tab(text: 'Kho đang giữ tiền'),
    const Tab(text: 'Đã chuyển cho người bán'),
  ];

  // List<CashOrderByDateEntity> filterMethod(
  //   List<CashOrderByDateEntity> currentItems,
  //   List<CashOrderByDateEntity> filteredItems,
  //   FilterCashTransferParams params,
  // ) {
  //   DateTime? filterDate = params.filterDate;
  //   String? filterShipper = params.filterShipper;

  //   List<CashOrderByDateEntity> rs = [...currentItems];

  //   if (filterDate != null) {
  //     filterDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
  //     rs.removeWhere((e) => e.date != filterDate);
  //   }

  //   if (filterShipper?.isNotEmpty == true) {
  //     for (int i = 0; i < rs.length; i++) {
  //       final filterCashOrders = rs[i].cashOrders.where((cash) => cash.shipperUsername == filterShipper).toList();
  //       rs[i] = rs[i].copyWith(cashOrders: filterCashOrders);
  //     }
  //     rs.removeWhere((e) => e.cashOrders.isEmpty); // after filter, maybe some date has no cash order
  //   }
  //   return rs;
  // }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    _warehouseUnderConfirmationListController = FilterListController(
        items: <CashOrderByDateEntity>[],
        filterParams: FilterCashTransferParams(),
        futureCallback: () => sl<CashRepository>().historyByWareHouse(HistoryType.warehouseUnderConfirmationReceived),
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
        })
      ..setFilterCallback(filterCashMethod)
      ..setFirstRunCallback(() => _warehouseUnderConfirmationListController.performFilter())
      ..init();

    _warehouseHoldingListController = FilterListController(
        items: <CashOrderByDateEntity>[],
        filterParams: FilterCashTransferParams(),
        futureCallback: () => sl<CashRepository>().historyByWareHouse(HistoryType.warehouseHolding),
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
        })
      ..setFilterCallback(filterCashMethod)
      ..setFirstRunCallback(() => _warehouseHoldingListController.performFilter())
      ..init();

    _warehouseTransferredListController = FilterListController(
        items: <CashOrderByDateEntity>[],
        filterParams: FilterCashTransferParams(),
        futureCallback: () => sl<CashRepository>().historyByWareHouse(HistoryType.warehouseHasTransferredToShop),
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
        })
      ..setFilterCallback(filterCashMethod)
      ..setFirstRunCallback(() => _warehouseTransferredListController.performFilter())
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
                //# under confirmation
                CustomScrollTabView.warehouse(
                  futureListController: _warehouseUnderConfirmationListController,
                  isSlidable: true,
                  onConfirmPressed: handleConfirmPressed,
                  onRefresh: () => _warehouseUnderConfirmationListController.refresh(),
                ),
                //# warehouse holding
                CustomScrollTabView.warehouse(
                  futureListController: _warehouseHoldingListController,
                  isSlidable: false,
                  onRefresh: () => _warehouseHoldingListController.refresh(),
                ),
                //# transferred to vendor
                CustomScrollTabView.warehouse(
                  futureListController: _warehouseTransferredListController,
                  isSlidable: false,
                  onRefresh: () => _warehouseTransferredListController.refresh(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleConfirmPressed(List<String> cashOrderIds, CashOrderByDateEntity cashOnDate) async {
    final warehouseUsername = context.read<AuthCubit>().state.currentUsername;
    if (warehouseUsername == null) return;

    final isConfirm = await showDialogToConfirm(
      context: context,
      title: 'Xác nhận đối soát',
      content:
          'Bạn đã nhận đủ ${ConversionUtils.formatCurrency(cashOnDate.totalMoney)} từ shipper chưa? Tiền sẽ được tự động chuyển cho người bán khi đơn hàng được hoàn thành.\n\nLưu ý: Toàn bộ (${cashOnDate.count} đơn hàng) trong danh sách sẽ được xác nhận.',
      contentTextAlign: TextAlign.start,
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
    );

    if ((isConfirm ?? false) && mounted) {
      await showDialogToPerform<RespData<CashOrderResp>>(context,
          dataCallback: () async {
            // return sl<CashRepository>().requestTransfersMoneyToWarehouseByShipper(
            //     TransferMoneyRequest(cashOrderIds: getCashOrderIdsByDate(date), waveHouseUsername: warehouseUsername));

            return await sl<CashRepository>().confirmTransfersMoneyByWarehouse(
                TransferMoneyRequest(cashOrderIds: cashOrderIds, waveHouseUsername: warehouseUsername));
          },
          onData: (data) {
            showToastResult(data as RespData, onSuccess: () {
              _warehouseUnderConfirmationListController.refreshAndFilter();
              _warehouseHoldingListController.refreshAndFilter();
              _warehouseTransferredListController.refreshAndFilter();
            });
          },
          closeBy: (context, result) => Navigator.of(context).pop(result));
    }
  }
}
