import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/entities/cash_order_by_date_entity.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/repository/cash_repository.dart';
import '../components/custom_scroll_tab_view.dart';

class CashOrderByWarehousePage extends StatefulWidget {
  const CashOrderByWarehousePage({super.key});

  @override
  State<CashOrderByWarehousePage> createState() => _CashOrderByWarehousePageState();
}

class _CashOrderByWarehousePageState extends State<CashOrderByWarehousePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>>
      _warehouseUnderConfirmationListController;
  late FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>>
      _warehouseHoldingListController;
  late FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>>
      _warehouseTransferredListController;

  final _tabs = <Tab>[
    const Tab(text: 'Chờ xác nhận'),
    const Tab(text: 'Kho đang giữ tiền'),
    const Tab(text: 'Đã chuyển cho người bán'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _warehouseUnderConfirmationListController = FutureListController(
      items: <CashOrderByDateEntity>[],
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
      },
    )..init();
    _warehouseHoldingListController = FutureListController(
      items: <CashOrderByDateEntity>[],
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
      },
    )..init();
    _warehouseTransferredListController = FutureListController(
      items: <CashOrderByDateEntity>[],
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
      },
    )..init();

    _warehouseUnderConfirmationListController.addListener(() => setState(() {}));
    _warehouseHoldingListController.addListener(() => setState(() {}));
    _warehouseTransferredListController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _warehouseUnderConfirmationListController.dispose();
    _warehouseHoldingListController.dispose();
    _warehouseTransferredListController.dispose();
    super.dispose();
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
                  // items: _warehouseUnderConfirmationListController.items,
                  isSlidable: true,
                  onConfirmPressed: handleConfirmPressed,
                  onRefresh: () {
                    _warehouseUnderConfirmationListController.refresh();
                  },
                ),
                //# warehouse holding
                CustomScrollTabView.warehouse(
                  futureListController: _warehouseHoldingListController,
                  // items: _warehouseHoldingListController.items,
                  isSlidable: false,
                  onRefresh: () {
                    _warehouseHoldingListController.refresh();
                  },
                ),
                //# transferred to vendor
                CustomScrollTabView.warehouse(
                  futureListController: _warehouseTransferredListController,
                  // items: _warehouseTransferredListController.items,
                  isSlidable: false,
                  onRefresh: () {
                    _warehouseTransferredListController.refresh();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleConfirmPressed(List<String> cashOrderIds) async {
    final warehouseUsername = context.read<AuthCubit>().state.currentUsername;
    if (warehouseUsername == null) return;

    await showDialogToConfirm(
      context: context,
      title: 'Xác nhận đối soát',
      content: 'Bạn đã nhận đủ tiền từ shipper chưa?',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
      onConfirm: () async {
        await sl<CashRepository>()
            .confirmTransfersMoneyByWarehouse(
                TransferMoneyRequest(cashOrderIds: cashOrderIds, waveHouseUsername: warehouseUsername))
            .then((respEither) =>
                showToastResult(respEither, onFinished: () => _warehouseUnderConfirmationListController.refresh()));
      },
    );
  }
}
