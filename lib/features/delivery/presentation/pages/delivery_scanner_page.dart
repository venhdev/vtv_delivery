import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/order.dart';

import '../../../../app_state.dart';
import '../../../../dependency_container.dart';
import '../../domain/repository/delivery_repository.dart';
import '../components/transport_info.dart';

//! (shipper_pickup) - shipper get order from shop -> API not detect cash payment >> PICKED_UP
//! (picker_store) - picker store order PICKED_UP >> WAREHOUSE --same1 --scan qr code of warehouse
enum DeliveryType {
  //*(picker_pickup) - picker get order from shop PICKUP_PENDING >> PICKED_UP
  //*(warehouse_store_shop) - warehouse get order from shop PICKUP_PENDING >> WAREHOUSE --case vendor come to warehouse to send order
  //*(warehouse_store_picker) - warehouse store order from picker PICKED_UP >> WAREHOUSE --same1
  //*(warehouse_store_shipper) - warehouse store order from shipper SHIPPING >> WAREHOUSE -- when ship failed
  //* (shipper_shipping) - shipper get order from warehouse WAREHOUSE >> SHIPPING
  //* (return_accept) - picker,shipper,warehouse accept return order RETURNED >> PICKED_UP
  //* (return_cancel) - picker,shipper,warehouse cancel return order RETURNED >> COMPLETED
  pickup,

  //* (shipper_delivered) - shipper deliver to customer SHIPPING >> DELIVERED
  //* (warehouse_delivered) - warehouse give order to customer WAREHOUSE >> DELIVERED
  delivered,

  //* (warehouse_forced_return) - warehouse forced return an order due to some reasons (e.g: customer not available)
  forcedReturn,

  //' (warehouse_store_return_picker) - warehouse store return order from picker PICKED_UP >> WAREHOUSE
  //' (warehouse_store_return_shipper) - warehouse store return order from sipper SHIPPING >> WAREHOUSE ??? should use SHIPPING ???
  //' (picker_pickup_return) - picker pickup return order from warehouse WAREHOUSE >> PICKED_UP ???
  //' (shipper_pickup_return) - shipper pickup return order from warehouse WAREHOUSE >> SHIPPING
  pickupReturn,

  // (shipper_delivered_return) - shipper deliver return order to shop SHIPPING >> DELIVERED
  // (picker_delivered_return) - shipper deliver return order to shop SHIPPING >> DELIVERED
  deliveredReturn,
}

class DeliveryScannerPage extends StatelessWidget {
  const DeliveryScannerPage({super.key});

  static const String routeName = '/scanner';

  Future<void> execute(
    BuildContext context,
    MobileScannerController controller,
    FRespData<TransportEntity> Function() callback,
  ) async {
    final resp = await showDialogToPerform(
      context,
      dataCallback: callback,
      closeBy: (context, result) => Navigator.of(context).pop(result),
    );
    if (resp == null) return;
    // when success, hide the overlay & start scanning again
    showToastResult(resp, onSuccess: () => controller.start());
  }

  String? confirmLabel(
    BuildContext context,
    TransportEntity transport,
    DeliveryType type,
  ) {
    final TypeWork currentWorkType = TypeWork.values.firstWhere(
      (e) => e.name == Provider.of<AppState>(context, listen: false).deliveryInfo?.typeWork,
      orElse: () => TypeWork.Unknown,
    );
    if (currentWorkType == TypeWork.Unknown) return null;

    switch (type) {
      case DeliveryType.pickup:
        if (transport.status == OrderStatus.PICKUP_PENDING && currentWorkType == TypeWork.PICKUP) {
          //# (picker_pickup)
          return 'Lấy hàng';
        } else if ((transport.status == OrderStatus.PICKUP_PENDING ||
                transport.status == OrderStatus.PICKED_UP ||
                transport.status == OrderStatus.SHIPPING) &&
            currentWorkType == TypeWork.WAREHOUSE) {
          //# (warehouse_store_shop, warehouse_store_picker, warehouse_store_shipper, warehouse_store_return_picker)
          return 'Lưu kho';
        } else if (transport.status == OrderStatus.WAREHOUSE && currentWorkType == TypeWork.SHIPPER) {
          //# (shipper_shipping)
          return 'Lấy hàng từ kho';
        } else if ((currentWorkType == TypeWork.PICKUP ||
                currentWorkType == TypeWork.SHIPPER ||
                currentWorkType == TypeWork.WAREHOUSE) &&
            transport.status == OrderStatus.RETURNED) {
          return 'Chấp nhận trả hàng';
        }

      case DeliveryType.delivered:
        if (transport.status == OrderStatus.PICKED_UP && currentWorkType == TypeWork.PICKUP) {
          return null;
        } else if (transport.status == OrderStatus.SHIPPING && currentWorkType == TypeWork.SHIPPER) {
          //# (shipper_delivered)
          return 'Giao hàng thành công';
        } else if (transport.status == OrderStatus.WAREHOUSE && currentWorkType == TypeWork.WAREHOUSE) {
          //# (warehouse_delivered)
          return 'Giao tại kho thành công';
        }

      case DeliveryType.forcedReturn:
        //# (warehouse_forced_return)
        if (currentWorkType == TypeWork.WAREHOUSE &&
            (transport.status == OrderStatus.WAREHOUSE || transport.status == OrderStatus.SHIPPING)) {
          return 'Trả hàng cho shop';
        }

      case DeliveryType.pickupReturn:
        //# warehouse_store_return_picker, warehouse_store_return_shipper
        if (currentWorkType == TypeWork.WAREHOUSE &&
            (transport.status == OrderStatus.PICKED_UP || transport.status == OrderStatus.SHIPPING)) {
          return 'Lưu kho đơn hoàn hàng';
        } else if ((currentWorkType == TypeWork.PICKUP || currentWorkType == TypeWork.SHIPPER) &&
            (transport.status == OrderStatus.WAREHOUSE)) {
          //# picker_pickup_return, shipper_pickup_return
          return 'Lấy đơn hoàn hàng từ kho';
        }

      case DeliveryType.deliveredReturn:
        //# shipper_delivered_return
        if (currentWorkType == TypeWork.SHIPPER && (transport.status == OrderStatus.SHIPPING)) {
          return 'Giao đơn hoàn hàng cho shop';
        } else if (currentWorkType == TypeWork.PICKUP && (transport.status == OrderStatus.PICKED_UP)) {
          //# picker_delivered_return
          return 'Lấy đơn hoàn hàng từ kho';
        }
    }
    return null;
  }

  void Function()? _handleOnConfirm(
    BuildContext context,
    MobileScannerController controller,
    TransportEntity transport,
    DeliveryType type,
  ) {
    final TypeWork currentWorkType = TypeWork.values.firstWhere(
      (e) => e.name == Provider.of<AppState>(context, listen: false).deliveryInfo?.typeWork,
      orElse: () => TypeWork.Unknown,
    );
    if (currentWorkType == TypeWork.Unknown) return null;

    switch (type) {
      case DeliveryType.pickup:
        if (transport.status == OrderStatus.PICKUP_PENDING && currentWorkType == TypeWork.PICKUP) {
          //# (picker_pickup) picker get order from shop
          return () async => await execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                  transport.transportId,
                  OrderStatus.PICKED_UP,
                  true,
                  transport.wardCodeShop,
                );
              });
        } else if ((transport.status == OrderStatus.PICKUP_PENDING ||
                transport.status == OrderStatus.PICKED_UP ||
                transport.status == OrderStatus.SHIPPING) &&
            currentWorkType == TypeWork.WAREHOUSE) {
          //# (warehouse_store_shop, warehouse_store_picker, warehouse_store_shipper, warehouse_store_return_picker)
          final warehouseWardCode = Provider.of<AppState>(context, listen: false).deliveryInfo!.wardCode;
          return () async {
            await execute(context, controller, () async {
              //? before change status to WAREHOUSE, if status is PICKUP_PENDING, change it to PICKED_UP first
              if (transport.status == OrderStatus.PICKUP_PENDING) {
                final respEither = await sl<DeliveryRepository>().updateStatusTransportByDeliver(
                  transport.transportId,
                  OrderStatus.PICKED_UP,
                  true,
                  transport.wardCodeShop,
                );
                respEither.fold(
                  (error) {
                    return Left(error);
                  },
                  (_) => {}, // change status to PICKED_UP success then continue
                );
              }

              return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                transport.transportId,
                OrderStatus.WAREHOUSE,
                true,
                warehouseWardCode,
              );
            });
          };
        } else if (transport.status == OrderStatus.WAREHOUSE && currentWorkType == TypeWork.SHIPPER) {
          //# (shipper_shipping)
          //? when shipper get order from warehouse, that order must be 'OrderStatus.WAREHOUSE'
          //? so just get the wardCode from the first handle
          final warehouseWardCode = transport.transportHandles.first.wardCode;
          return () async => await execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                  transport.transportId,
                  OrderStatus.SHIPPING,
                  true,
                  warehouseWardCode,
                );
              });
        } else if (transport.status == OrderStatus.RETURNED &&
            (currentWorkType == TypeWork.PICKUP ||
                currentWorkType == TypeWork.SHIPPER ||
                currentWorkType == TypeWork.WAREHOUSE)) {
          //# (return_accept) - picker,shipper,warehouse accept return order RETURNED >> ??
          return () async =>
              await execute(context, controller, () => sl<DeliveryRepository>().acceptReturn(transport.transportId));
        } else {
          return null;
        }

      case DeliveryType.delivered:
        if (transport.status == OrderStatus.PICKED_UP && currentWorkType == TypeWork.PICKUP) {
          return () async {
            execute(context, controller, () {
              return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                transport.transportId,
                OrderStatus.WAREHOUSE,
                true,
                transport.wardCodeCustomer,
              );
            });
          };
        } else if (transport.status == OrderStatus.SHIPPING && currentWorkType == TypeWork.SHIPPER) {
          //# (shipper_delivered)
          return () async {
            execute(context, controller, () {
              return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                transport.transportId,
                OrderStatus.DELIVERED,
                true,
                transport.wardCodeCustomer,
              );
            });
          };
        } else if (transport.status == OrderStatus.WAREHOUSE && currentWorkType == TypeWork.WAREHOUSE) {
          //# (warehouse_delivered)
          final warehouseWardCode = transport.transportHandles.first.wardCode;
          return () async {
            execute(context, controller, () {
              return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                transport.transportId,
                OrderStatus.DELIVERED,
                true,
                warehouseWardCode,
              );
            });
          };
        } else {
          return null;
        }

      case DeliveryType.forcedReturn:
        //# (warehouse_forced_return)
        if (currentWorkType == TypeWork.WAREHOUSE &&
            (transport.status == OrderStatus.WAREHOUSE || transport.status == OrderStatus.SHIPPING)) {
          return () async => await execute(
                context,
                controller,
                () => sl<DeliveryRepository>().forcedReturnOrderByWarehouse(transport.transportId),
              );
        } else {
          return null;
        }

      case DeliveryType.pickupReturn:
        //# warehouse_store_return_picker, warehouse_store_return_shipper
        if (currentWorkType == TypeWork.WAREHOUSE &&
            (transport.status == OrderStatus.PICKED_UP || transport.status == OrderStatus.SHIPPING)) {
          return () => execute(context, controller, () {
                final warehouseWardCode = Provider.of<AppState>(context, listen: false).deliveryInfo!.wardCode;
                return sl<DeliveryRepository>().updateStatusTransportByDeliverOfReturnOrder(
                  transport.transportId,
                  OrderStatus.WAREHOUSE,
                  true,
                  warehouseWardCode,
                );
              });
        } else if ((currentWorkType == TypeWork.PICKUP) && (transport.status == OrderStatus.WAREHOUSE)) {
          //# picker_pickup_return
          return () => execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliverOfReturnOrder(
                  transport.transportId,
                  OrderStatus.PICKED_UP,
                  true,
                  transport.transportHandles.first.wardCode, //? get wardCodeShop from the first handle
                );
              });
        } else if ((currentWorkType == TypeWork.SHIPPER) && (transport.status == OrderStatus.WAREHOUSE)) {
          //# shipper_pickup_return
          return () => execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliverOfReturnOrder(
                  transport.transportId,
                  OrderStatus.SHIPPING,
                  true,
                  transport.transportHandles.first.wardCode, //? get wardCodeShop from the first handle
                );
              });
        } else {
          return null;
        }

      case DeliveryType.deliveredReturn:
        //# shipper_delivered_return
        if (currentWorkType == TypeWork.SHIPPER && (transport.status == OrderStatus.SHIPPING)) {
          return () => execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliverOfReturnOrder(
                  transport.transportId,
                  OrderStatus.DELIVERED,
                  true,
                  transport.wardCodeShop,
                );
              });
        } else if (currentWorkType == TypeWork.PICKUP && (transport.status == OrderStatus.PICKED_UP)) {
          //# picker_delivered_return
          return () => execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliverOfReturnOrder(
                  transport.transportId,
                  OrderStatus.DELIVERED,
                  true,
                  transport.wardCodeShop,
                );
              });
        } else {
          return null;
        }

      default:
        return null;
    }
  }

  String? cancelLabel(
    BuildContext context,
    TransportEntity transport,
    DeliveryType type,
  ) {
    final TypeWork currentWorkType = TypeWork.values.firstWhere(
      (e) => e.name == Provider.of<AppState>(context, listen: false).deliveryInfo?.typeWork,
      orElse: () => TypeWork.Unknown,
    );
    if (currentWorkType == TypeWork.Unknown) return null;
    switch (type) {
      case DeliveryType.pickup:
        if ((currentWorkType == TypeWork.PICKUP ||
                currentWorkType == TypeWork.SHIPPER ||
                currentWorkType == TypeWork.WAREHOUSE) &&
            transport.status == OrderStatus.RETURNED) {
          return 'Không đạt yêu cầu';
        }
      default:
        return null;
    }
    return null;
  }

  void Function()? _handleOnCancel(
    BuildContext context,
    MobileScannerController controller,
    TransportEntity transport,
    DeliveryType type,
  ) {
    final TypeWork currentWorkType = TypeWork.values.firstWhere(
      (e) => e.name == Provider.of<AppState>(context, listen: false).deliveryInfo?.typeWork,
      orElse: () => TypeWork.Unknown,
    );
    if (currentWorkType == TypeWork.Unknown) return null;

    if (type == DeliveryType.pickup && transport.status == OrderStatus.RETURNED) {
      return () async {
        execute(context, controller, () {
          return sl<DeliveryRepository>().cancelReturn(transport.transportId);
        });
      };
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final type = ModalRoute.of(context)!.settings.arguments as DeliveryType;

    return QrScanner(
      options: (context, controller) {
        controller.start();
        controller.barcodes.listen((data) {
          controller.stop();
          log('Scanned: ${data.barcodes.first.rawValue}');
          log('Scanned !context.mounted: ${!context.mounted}');
          // if (context.mounted) {
          //   Navigator.pop(context, data.barcodes.first.rawValue!);
          // }
        });
      },
      overlayBuilder: (context, constraints, controller) {
        return StreamBuilder(
          stream: controller.barcodes,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString(), style: const TextStyle(color: Colors.red));
            }

            final scannedBarcodes = snapshot.data?.barcodes ?? [];
            if (scannedBarcodes.isEmpty || controller.value.isRunning) {
              return const SizedBox.shrink();
            }

            if (ValidationUtils.isUUID(scannedBarcodes.first.rawValue)) {
              final transportId = scannedBarcodes.first.rawValue!;
              return FutureBuilder(
                  future: sl<DeliveryRepository>().getTransportById(transportId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!.fold(
                        (error) => MessageScreen.error(error.message),
                        (ok) => TransportInfo(
                          transport: ok.data!,
                          onReScan: () {
                            controller.start();
                          },
                          confirmLabel: confirmLabel(context, ok.data!, type),
                          onConfirm: _handleOnConfirm(context, controller, ok.data!, type),
                          cancelLabel: cancelLabel(context, ok.data!, type),
                          onCancel: _handleOnCancel(context, controller, ok.data!, type),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  });
            } else {
              return const Text(
                'QR code không hợp lệ!',
                overflow: TextOverflow.fade,
                style: TextStyle(color: Colors.white),
              );
            }
          },
        );
      },
    );
  }
}
