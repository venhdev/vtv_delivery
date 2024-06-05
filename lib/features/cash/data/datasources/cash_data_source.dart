import 'package:delivery/core/constants/delivery_api.dart';
import 'package:dio/dio.dart';
import 'package:vtv_common/core.dart';

import '../../domain/entities/cash_by_date_entity.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/entities/response/cash_order_response.dart';

abstract class CashDataSource {
  //# cash-order-controller
  // POST
  // /api/shipping/cash-order/updates/transfers-money-warehouse
  // const String kAPICashOrderTransfersMoneyWarehouseURL = '/shipping/cash-order/updates/transfers-money-warehouse';
  Future<SuccessResponse<CashOrderResp>> transfersMoneyWarehouseByShipper(TransferMoneyRequest req);
  // POST
  // /api/shipping/cash-order/updates/confirm-money-warehouse
  // const String kAPICashOrderConfirmMoneyWarehouseURL = '/shipping/cash-order/updates/confirm-money-warehouse';
  Future<SuccessResponse<CashOrderResp>> confirmTransfersMoneyByWarehouse(TransferMoneyRequest req);

  // GET
  // /api/shipping/cash-order/list-by-wave-house
  // const String kAPICashOrderListByWareHouseURL = '/shipping/cash-order/list-by-wave-house';
  Future<SuccessResponse<CashOrderResp>> listByWareHouse();

  // GET
  // /api/shipping/cash-order/history-by-warehouse
  // const String kAPICashOrderHistoryByWarehouseURL = '/shipping/cash-order/history-by-warehouse';
  Future<SuccessResponse<List<CashByDateEntity>>> historyByWareHouse(
      ({bool warehouseHold, bool handlePayment}) warehouseType);

  // GET
  // /api/shipping/cash-order/history-by-shipper
  // const String kAPICashOrderHistoryByShipperURL = '/shipping/cash-order/history-by-shipper';
  Future<SuccessResponse<List<CashByDateEntity>>> historyByShipper(({bool shipperHold, bool shipping}) shipperType);

  // GET
  // /api/shipping/cash-order/all-by-shipper
  // const String kAPICashOrderAllByShipperURL = '/shipping/cash-order/all-by-shipper';
  Future<SuccessResponse<CashOrderResp>> listByShipper();
}

class ShopDataSourceImpl implements CashDataSource {
  final Dio _dio;

  ShopDataSourceImpl(this._dio);

  @override
  Future<SuccessResponse<CashOrderResp>> confirmTransfersMoneyByWarehouse(TransferMoneyRequest req) async {
    final url = uriBuilder(path: kAPICashOrderConfirmMoneyWarehouseURL);

    final response = await _dio.postUri(url, data: req.toJson());

    return handleDioResponse<CashOrderResp, MapS>(
      response,
      url,
      parse: (jsonMap) => CashOrderResp.fromMap(jsonMap),
    );
  }

  @override
  Future<SuccessResponse<CashOrderResp>> transfersMoneyWarehouseByShipper(TransferMoneyRequest req) async {
    final url = uriBuilder(path: kAPICashOrderTransfersMoneyWarehouseURL);

    final response = await _dio.postUri(url, data: req.toJson());

    return handleDioResponse<CashOrderResp, MapS>(
      response,
      url,
      parse: (jsonMap) => CashOrderResp.fromMap(jsonMap),
    );
  }

  @override
  Future<SuccessResponse<List<CashByDateEntity>>> historyByShipper(
    ({bool shipperHold, bool shipping}) shipperType,
  ) async {
    final url = uriBuilder(
        path: kAPICashOrderHistoryByShipperURL,
        queryParameters: {
          'shipperHold': shipperType.shipperHold,
          'shipping': shipperType.shipping,
        }.map((key, value) => MapEntry(key, value.toString())));

    final response = await _dio.getUri(url);

    return handleDioResponse<List<CashByDateEntity>, MapS>(
      response,
      url,
      parse: (jsonMap) => (jsonMap['cashOrdersByDateDTOs'] as List).map((e) => CashByDateEntity.fromMap(e)).toList(),
    );
  }

  @override
  Future<SuccessResponse<List<CashByDateEntity>>> historyByWareHouse(
      ({bool handlePayment, bool warehouseHold}) warehouseType) async {
    final url = uriBuilder(
        path: kAPICashOrderHistoryByWarehouseURL,
        queryParameters: {
          'warehouseHold': warehouseType.warehouseHold,
          'handlePayment': warehouseType.handlePayment,
        }.map((key, value) => MapEntry(key, value.toString())));

    final response = await _dio.getUri(url);

    return handleDioResponse<List<CashByDateEntity>, MapS>(
      response,
      url,
      parse: (jsonMap) => (jsonMap['cashOrdersByDateDTOs'] as List).map((e) => CashByDateEntity.fromMap(e)).toList(),
    );
  }

  @override
  Future<SuccessResponse<CashOrderResp>> listByShipper() async {
    final url = uriBuilder(path: kAPICashOrderAllByShipperURL);

    final response = await _dio.getUri(url);

    return handleDioResponse<CashOrderResp, MapS>(
      response,
      url,
      parse: (jsonMap) => CashOrderResp.fromMap(jsonMap),
    );
  }

  @override
  Future<SuccessResponse<CashOrderResp>> listByWareHouse() async {
    final url = uriBuilder(path: kAPICashOrderListByWareHouseURL);

    final response = await _dio.getUri(url);

    return handleDioResponse<CashOrderResp, MapS>(
      response,
      url,
      parse: (jsonMap) => CashOrderResp.fromMap(jsonMap),
    );
  }
}
