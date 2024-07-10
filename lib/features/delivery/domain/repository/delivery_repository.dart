import 'package:vtv_common/core.dart';
import 'package:vtv_common/order.dart';

import '../entities/deliver_entity.dart';
import '../entities/res/transport_resp.dart';

abstract class DeliveryRepository {
  //# deliver-controller
  FRespData<DeliverEntity> getDeliverInfo();

  //# transport-controller
  FRespData<TransportEntity> acceptReturn(String transportId);
  FRespData<TransportEntity> cancelReturn(String transportId);
  FRespData<TransportEntity> forcedReturnOrderByWarehouse(String transportId);
  FRespData<TransportEntity> getTransportById(String transportId);
  FRespData<String> getCustomerWardCodeByTransportId(String transportId); // custom
  FRespData<TransportResp> getTransportByWardCode(String wardCode);
  FRespData<TransportResp> getTransportByWardWork();
  FRespData<TransportEntity> updateStatusTransportByDeliver(
    String transportId,
    OrderStatus status,
    bool handled,
    String wardCode,
  );
  FRespData<TransportEntity> updateStatusTransportByDeliverOfReturnOrder(
    String transportId,
    OrderStatus status,
    bool handled,
    String wardCode,
  );
}
