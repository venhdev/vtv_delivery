import '../../dependency_container.dart';
import '../../features/delivery/domain/entities/deliver_entity.dart';
import '../../features/delivery/domain/repository/delivery_repository.dart';

class DeliveryHandler {
  static Future<DeliverEntity?> getDeliverInfo() async {
    return await sl<DeliveryRepository>().getDeliverInfo().then((respEither) {
      return respEither.fold(
        (error) => null,
        (ok) => ok.data,
      );
    });
  }
}
