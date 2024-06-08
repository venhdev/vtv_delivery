import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/entities/cash_order_by_date_entity.dart';
import '../../domain/repository/cash_repository.dart';
import '../components/cash_item.dart';

class CashOrderPage extends StatefulWidget {
  const CashOrderPage({super.key});

  @override
  State<CashOrderPage> createState() => _CashOrderPageState();
}

class _CashOrderPageState extends State<CashOrderPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>> _shipperHoldingListController;
  late FutureListController<CashOrderByDateEntity, RespData<List<CashOrderByDateEntity>>>
      _shipperTransferredListController;

  final _tabs = <Tab>[
    const Tab(text: 'Đang giữ tiền'),
    const Tab(text: 'Đã nộp kho'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _shipperHoldingListController = FutureListController(
      items: <CashOrderByDateEntity>[],
      futureData: sl<CashRepository>().historyByShipper(HistoryType.shipperHolding),
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
    _shipperTransferredListController = FutureListController(
      items: <CashOrderByDateEntity>[],
      futureData: sl<CashRepository>().historyByShipper(HistoryType.shipperTransferred),
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

    _shipperHoldingListController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _shipperHoldingListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shipperHoldingListController.items.isEmpty) {
      return const MessageScreen(message: 'Không có dữ liệu');
    }
    return SafeArea(
      child: Column(
        children: [
          TabBar(padding: EdgeInsets.zero, controller: _tabController, tabs: _tabs),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                //# holding
                buildTapView(_shipperHoldingListController.items),
                //# transferred
                buildTapView(_shipperTransferredListController.items),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildTapView(List<CashOrderByDateEntity> items) {
    return CustomScrollView(
      slivers: [
        for (final cashOnDate in items) ...[
          SliverToBoxAdapter(child: summaryCashOnDate(cashOnDate)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: cashOnDate.cashOrders.length,
              (context, index) => Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  children: [
                    for (final cash in cashOnDate.cashOrders) CashItem(cash: cash),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Card summaryCashOnDate(CashOrderByDateEntity cashOnDate) {
    return Card(
      color: Colors.grey[200],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListDynamic(list: {
          'Ngày:': ConversionUtils.convertDateTimeToString(cashOnDate.date),
          'Số đơn đã giao:': cashOnDate.cashOrders.length.toString(),
          'Tổng tiền thu:': ConversionUtils.formatCurrency(cashOnDate.totalMoney),
        }),
      ),
    );
  }
}
