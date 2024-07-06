import '../../domain/entities/response/cash_order_by_date_resp.dart';
import '../components/custom_scroll_tab_view.dart';

List<CashOrderByDateResp> filterCashMethod(
  List<CashOrderByDateResp> currentItems,
  List<CashOrderByDateResp> filteredItems,
  FilterCashTransferParams params,
) {
  DateTime? filterDate = params.filterDate;
  String? filterShipper = params.filterShipper;

  List<CashOrderByDateResp> rs = [...currentItems];

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
