import 'package:delivery/features/cash/domain/entities/request/transfer_money_request.dart';
import 'package:vtv_common/core.dart';

import '../entities/cash_by_date_entity.dart';
import '../entities/response/cash_order_response.dart';

abstract class CashRepository {
  //# cash-order-controller
  // POST
  // /api/shipping/cash-order/updates/transfers-money-warehouse
  // const String kAPICashOrderTransfersMoneyWarehouseURL = '/shipping/cash-order/updates/transfers-money-warehouse';
  FRespData<CashOrderResp> transfersMoneyWarehouseByShipper(TransferMoneyRequest req);
  // POST
  // /api/shipping/cash-order/updates/confirm-money-warehouse
  // const String kAPICashOrderConfirmMoneyWarehouseURL = '/shipping/cash-order/updates/confirm-money-warehouse';
  FRespData<CashOrderResp> confirmTransfersMoneyByWarehouse(TransferMoneyRequest req);

  // GET
  // /api/shipping/cash-order/list-by-wave-house
  // const String kAPICashOrderListByWareHouseURL = '/shipping/cash-order/list-by-wave-house';
  FRespData<CashOrderResp> listByWareHouse();

  // GET
  // /api/shipping/cash-order/history-by-warehouse
  // const String kAPICashOrderHistoryByWarehouseURL = '/shipping/cash-order/history-by-warehouse';
  FRespData<List<CashByDateEntity>> historyByWareHouse(({bool warehouseHold, bool handlePayment}) warehouseType);

  // GET
  // /api/shipping/cash-order/history-by-shipper
  // const String kAPICashOrderHistoryByShipperURL = '/shipping/cash-order/history-by-shipper';
  FRespData<List<CashByDateEntity>> historyByShipper(({bool shipperHold, bool shipping}) shipperType);

  // GET
  // /api/shipping/cash-order/all-by-shipper
  // const String kAPICashOrderAllByShipperURL = '/shipping/cash-order/all-by-shipper';
  FRespData<CashOrderResp> listByShipper();
}

class HistoryType {
  //# shipper
  /// shipper is holding order (not shipping to customer yet)
  static ({bool shipperHold, bool shipping}) shipperShipping = (shipperHold: false, shipping: true);

  /// shipper is holding money (shipping to customer successfully, but not yet transferred to warehouse)
  static ({bool shipperHold, bool shipping}) shipperHolding = (shipperHold: true, shipping: false);

  /// shipper has transferred money to warehouse (maybe need to confirm by warehouse)
  static ({bool shipperHold, bool shipping}) shipperTransferred = (shipperHold: false, shipping: false);

  //# warehouse
  /// under review transferred from shipper to warehouse
  static ({bool warehouseHold, bool handlePayment}) warehouseUnderReviewTransferred =
      (warehouseHold: false, handlePayment: false);

  /// warehouse is holding money
  static ({bool warehouseHold, bool handlePayment}) warehouseHolding = (warehouseHold: true, handlePayment: false);

  /// warehouse has transferred money to shop
  static ({bool warehouseHold, bool handlePayment}) warehouseHasTransferredToShop =
      (warehouseHold: false, handlePayment: true);
}
