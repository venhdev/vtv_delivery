import '../../domain/entities/cash_order_by_date_entity.dart';
import '../components/custom_scroll_tab_view.dart';

List<CashOrderByDateEntity> filterCashMethod(
  List<CashOrderByDateEntity> currentItems,
  List<CashOrderByDateEntity> filteredItems,
  FilterCashTransferParams params,
) {
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
