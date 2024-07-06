import 'package:dartz/dartz.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/order.dart';

import '../../domain/entities/deliver_entity.dart';
import '../../domain/entities/res/transport_resp.dart';
import '../../domain/repository/delivery_repository.dart';
import '../data_sources/delivery_data_source.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryDataSource _dataSource;

  DeliveryRepositoryImpl(this._dataSource);

  @override
  FRespData<DeliverEntity> getDeliverInfo() async {
    return await handleDataResponseFromDataSource(dataCallback: () => _dataSource.getDeliverInfo());
  }

  @override
  FRespData<TransportResp> getTransportByWardCode(String wardCode) async {
    return await handleDataResponseFromDataSource(dataCallback: () => _dataSource.getTransportByWardCode(wardCode));
  }

  @override
  FRespData<TransportEntity> updateStatusTransportByDeliver(
    String transportId,
    OrderStatus status,
    bool handled,
    String wardCode,
  ) async {
    return await handleDataResponseFromDataSource(
      dataCallback: () => _dataSource.updateStatusTransportByDeliver(transportId, status, handled, wardCode),
    );
  }

  @override
  FRespData<TransportResp> getTransportByWardWork() async {
    return await handleDataResponseFromDataSource(dataCallback: () => _dataSource.getTransportByWardWork());
  }

  @override
  FRespData<TransportEntity> getTransportById(String transportId) async {
    return await handleDataResponseFromDataSource(dataCallback: () => _dataSource.getTransportById(transportId));
  }

  @override
  FRespData<String> getCustomerWardCodeByTransportId(String transportId) async {
    final resp = await handleDataResponseFromDataSource(dataCallback: () => _dataSource.getTransportById(transportId));

    return resp.fold(
      (error) => Left(error),
      (ok) => Right(SuccessResponse(data: ok.data!.wardCodeCustomer)),
    );
  }

  @override
  FRespData<TransportEntity> cancelReturn(String transportId) async {
    return await handleDataResponseFromDataSource(dataCallback: () => _dataSource.cancelReturn(transportId));
  }

  @override
  FRespData<TransportEntity> successReturn(String transportId) async {
    return await handleDataResponseFromDataSource(dataCallback: () => _dataSource.successReturn(transportId));
  }
}
