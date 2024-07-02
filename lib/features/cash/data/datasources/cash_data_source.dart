import 'package:delivery/core/constants/delivery_api.dart';
import 'package:dio/dio.dart';
import 'package:vtv_common/core.dart';

import '../../domain/entities/cash_order_by_date_entity.dart';
import '../../domain/entities/request/transfer_money_request.dart';
import '../../domain/entities/response/cash_order_response.dart';

abstract class CashDataSource {
  //# cash-order-controller
  Future<SuccessResponse<CashOrderResp>> transfersMoneyWarehouseByShipper(TransferMoneyRequest req);
  Future<SuccessResponse<CashOrderResp>> confirmTransfersMoneyByWarehouse(TransferMoneyRequest req);
  Future<SuccessResponse<CashOrderResp>> listByWareHouse();
  Future<SuccessResponse<List<CashOrderByDateEntity>>> historyByWareHouse(
      ({bool warehouseHold, bool handlePayment}) warehouseType);
  Future<SuccessResponse<List<CashOrderByDateEntity>>> historyByShipper(
      ({bool shipperHold, bool shipping}) shipperType);
  Future<SuccessResponse<CashOrderResp>> listByShipper();
}

class CashDataSourceImpl implements CashDataSource {
  final Dio _dio;

  CashDataSourceImpl(this._dio);

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
  Future<SuccessResponse<List<CashOrderByDateEntity>>> historyByShipper(
    ({bool shipperHold, bool shipping}) shipperType,
  ) async {
    final url = uriBuilder(
        path: kAPICashOrderHistoryByShipperURL,
        queryParameters: {
          'shipperHold': shipperType.shipperHold,
          'shipping': shipperType.shipping,
        }.map((key, value) => MapEntry(key, value.toString())));

    final response = await _dio.getUri(url);

    return handleDioResponse<List<CashOrderByDateEntity>, MapS>(
      response,
      url,
      parse: (jsonMap) =>
          (jsonMap['cashOrdersByDateDTOs'] as List).map((e) => CashOrderByDateEntity.fromMap(e)).toList(),
    );
  }

  @override
  Future<SuccessResponse<List<CashOrderByDateEntity>>> historyByWareHouse(
      ({bool handlePayment, bool warehouseHold}) warehouseType) async {
    final url = uriBuilder(
        path: kAPICashOrderHistoryByWarehouseURL,
        queryParameters: {
          'warehouseHold': warehouseType.warehouseHold,
          'handlePayment': warehouseType.handlePayment,
        }.map((key, value) => MapEntry(key, value.toString())));

    final response = await _dio.getUri(url);

    return handleDioResponse<List<CashOrderByDateEntity>, MapS>(
      response,
      url,
      parse: (jsonMap) =>
          (jsonMap['cashOrdersByDateDTOs'] as List).map((e) => CashOrderByDateEntity.fromMap(e)).toList(),
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
