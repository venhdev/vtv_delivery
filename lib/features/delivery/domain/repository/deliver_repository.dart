import 'package:vtv_common/core.dart';
import 'package:vtv_common/order.dart';

import '../entities/deliver_entity.dart';
import '../entities/res/transport_resp.dart';

abstract class DeliverRepository {
  FRespData<DeliverEntity> getDeliverInfo();

  //! transport-controller
  /// use to get transport order by ward code
  FRespData<TransportResp> getTransportByWardCode(String wardCode);
  FRespData<TransportResp> getTransportByWardWork();
  FRespData<TransportEntity> updateStatusTransportByDeliver(
    String transportId,
    OrderStatus status,
    bool handled,
    String wardCode,
  );
}
