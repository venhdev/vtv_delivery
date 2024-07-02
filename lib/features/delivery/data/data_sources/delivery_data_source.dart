import 'package:dio/dio.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/order.dart';

import '../../../../core/constants/delivery_api.dart';
import '../../domain/entities/deliver_entity.dart';
import '../../domain/entities/res/transport_resp.dart';

abstract class DeliveryDataSource {
  //# deliver-controller
  Future<SuccessResponse<DeliverEntity>> getDeliverInfo();

  //# transport-controller
  Future<SuccessResponse<TransportEntity>> getTransportById(String transportId);
  Future<SuccessResponse<TransportResp>> getTransportByWardCode(String wardCode);
  Future<SuccessResponse<TransportResp>> getTransportByWardWork();
  Future<SuccessResponse<TransportEntity>> updateStatusTransportByDeliver(
    String transportId,
    OrderStatus status,
    bool handled,
    String wardCode,
  );
}

class DeliverDataSourceImpl implements DeliveryDataSource {
  final Dio _dio;

  DeliverDataSourceImpl(this._dio);

  @override
  Future<SuccessResponse<DeliverEntity>> getDeliverInfo() async {
    final url = uriBuilder(path: kAPIDeliverInfoURL);

    final response = await _dio.getUri(url);

    return handleDioResponse<DeliverEntity, Map<String, dynamic>>(
      response,
      url,
      parse: (jsonMap) => DeliverEntity.fromMap(jsonMap['deliverDTO']),
    );
  }

  @override
  Future<SuccessResponse<TransportResp>> getTransportByWardCode(String wardCode) async {
    final url = uriBuilder(path: '$kAPITransportGetWardURL/$wardCode');

    final response = await _dio.getUri(url);

    return handleDioResponse<TransportResp, Map<String, dynamic>>(
      response,
      url,
      parse: (jsonMap) => TransportResp.fromMap(jsonMap),
    );
  }

  @override
  Future<SuccessResponse<TransportEntity>> updateStatusTransportByDeliver(
      String transportId, OrderStatus status, bool handled, String wardCode) async {
    final url = uriBuilder(path: '$kAPITransportUpdateStatusURL/$transportId', queryParameters: {
      'status': status.name,
      'handled': handled.toString(),
      'wardCode': wardCode,
    });

    final response = await _dio.patchUri(url);

    return handleDioResponse<TransportEntity, Map<String, dynamic>>(
      response,
      url,
      parse: (jsonMap) => TransportEntity.fromMap(jsonMap['transportDTO']),
    );
  }

  @override
  Future<SuccessResponse<TransportResp>> getTransportByWardWork() async {
    final url = uriBuilder(path: kAPITransportGetByWardWorkURL);

    final response = await _dio.getUri(url);

    return handleDioResponse<TransportResp, Map<String, dynamic>>(
      response,
      url,
      parse: (jsonMap) => TransportResp.fromMap(jsonMap),
    );
  }
  
  @override
  Future<SuccessResponse<TransportEntity>> getTransportById(String transportId) async {
    final url = uriBuilder(path: '$kAPITransportGetURL/$transportId');

    final response = await _dio.getUri(url);

    return handleDioResponse<TransportEntity, Map<String, dynamic>>(
      response,
      url,
      parse: (jsonMap) => TransportEntity.fromMap(jsonMap['transportDTO']),
    );
  }
}
