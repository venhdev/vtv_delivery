import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/entities/cash_order_by_date_entity.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/repository/cash_repository.dart';
import '../components/custom_scroll_tab_view.dart';

class CashOrderByShipperPage extends StatefulWidget {
  const CashOrderByShipperPage({super.key});

  @override
  State<CashOrderByShipperPage> createState() => _CashOrderByShipperPageState();
}

class _CashOrderByShipperPageState extends State<CashOrderByShipperPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _shipperHoldingListController;
  late FilterListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>, FilterCashTransferParams>
      _shipperTransferredListController;

  final _tabs = <Tab>[
    const Tab(text: 'Đang giữ tiền'),
    const Tab(text: 'Đã nộp kho'),
  ];

  List<CashOrderByDateEntity> filterMethod(currentItems, filteredItems, params) {
    DateTime? filterDate = params.filterDate;
    String? filterShipper = params.filterShipper;

    List<CashOrderByDateEntity> rs = [...currentItems];

    if (filterDate != null) {
      filterDate = DateTime(filterDate.year, filterDate.month, filterDate.day);
      rs.removeWhere((e) => e.date != filterDate);
    }

    if (filterShipper?.isNotEmpty == true) {
      for (int i = 0; i < rs.length; i++) {
        final filterCashOrders = rs[i].cashOrders.where((cash) => cash.shipperUsername == filterShipper).toList();
        rs[i] = rs[i].copyWith(cashOrders: filterCashOrders);
      }
      rs.removeWhere((e) => e.cashOrders.isEmpty); // after filter, maybe some date has no cash order
    }
    return rs;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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
      ..setFilterCallback(filterMethod)
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
      ..setFilterCallback(filterMethod)
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

  void handleInsertPressed(DateTime date) async {
    final warehouseUsername = await showDialogWithTextField(
      context: context,
      title: 'Mã kho',
      hintText: 'Nhập mã kho',
    ) as String?;
    if (warehouseUsername == null || !mounted) return;

    await showDialogToPerform(context,
        dataCallback: () async {
          sl<CashRepository>()
              .requestTransfersMoneyToWarehouseByShipper(
                  TransferMoneyRequest(cashOrderIds: getCashOrderIdsByDate(date), waveHouseUsername: warehouseUsername))
              .then((respEither) => showToastResult(respEither));
        },
        closeBy: (context, result) => Navigator.of(context).pop(result));
  }

  void handleScanPressed(DateTime date) async {
    final warehouseUsername = await Navigator.of(context).pushNamed('/scan') as String?;
    if (warehouseUsername == null || !mounted) return;

    showDialogToConfirm(
      context: context,
      title: 'Gửi yêu cầu đối soát',
      content: 'Yêu cầu đối soát sẽ được gửi cho kho $warehouseUsername. Bạn chắc chắn chứ?',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
      onConfirm: () async {
        await sl<CashRepository>()
            .requestTransfersMoneyToWarehouseByShipper(
                TransferMoneyRequest(cashOrderIds: getCashOrderIdsByDate(date), waveHouseUsername: warehouseUsername))
            .then((respEither) => showToastResult(respEither));
      },
    );
  }
}
