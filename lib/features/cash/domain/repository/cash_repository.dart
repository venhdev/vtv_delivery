import 'package:delivery/features/cash/domain/entities/request/transfer_money_request.dart';
import 'package:vtv_common/core.dart';

import '../entities/response/cash_order_by_date_resp.dart';
import '../entities/response/cash_order_detail_resp.dart';
import '../entities/response/cash_order_resp.dart';

abstract class CashRepository {
  //# cash-order-controller
  FRespData<CashOrderResp> requestTransfersMoneyToWarehouseByShipper(TransferMoneyRequest req);
  FRespData<CashOrderResp> confirmTransfersMoneyByWarehouse(TransferMoneyRequest req);
  // FRespData<CashOrderResp> listByWareHouse();
  FRespData<List<CashOrderByDateResp>> historyByWareHouse(({bool warehouseHold, bool handlePayment}) warehouseType);
  FRespData<List<CashOrderByDateResp>> historyByShipper(({bool shipperHold, bool shipping}) shipperType);
  FRespData<CashOrderDetailResp> getCashOrderDetailById(String cashOrderId);
}

class HistoryType {
  //# shipper
  /// shipper is holding order (not shipping to customer yet) 
  //NOTE: only work when get order from warehouse (not from shop --this case no cash created)
  static ({bool shipperHold, bool shipping}) shipperShipping = (shipperHold: false, shipping: true);

  /// shipper is holding money (shipping to customer successfully, but not yet transferred to warehouse)
  static ({bool shipperHold, bool shipping}) shipperHolding = (shipperHold: true, shipping: false);

  /// shipper has transferred money to warehouse (maybe need to confirm by warehouse)
  static ({bool shipperHold, bool shipping}) shipperTransferred = (shipperHold: false, shipping: false);

  //# warehouse
  /// under review transferred from shipper to warehouse
  static ({bool warehouseHold, bool handlePayment}) warehouseUnderConfirmationReceived =
      (warehouseHold: false, handlePayment: false);

  /// warehouse is holding money
  static ({bool warehouseHold, bool handlePayment}) warehouseHolding = (warehouseHold: true, handlePayment: false);

  /// warehouse has transferred money to shop
  static ({bool warehouseHold, bool handlePayment}) warehouseHasTransferredToShop =
      (warehouseHold: false, handlePayment: true);
}
