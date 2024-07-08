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

enum DeliveryType {
  //*(1) - picker get order from shop PICKUP_PENDING >> PICKED_UP
  //*!(2) - warehouse get order from shop PICKUP_PENDING >> WAREHOUSE --case vendor come to warehouse to send order
  //*(3) - warehouse get order from picker PICKED_UP >> WAREHOUSE --same1
  //*(3'1) - warehouse get order from shipper SHIPPING >> WAREHOUSE -- when ship failed
  //!(4) - shipper get order from shop -> API not detect cash payment >> PICKED_UP
  //* (5) - shipper get order from warehouse WAREHOUSE >> SHIPPING
  //(return_accept) - picker,shipper,warehouse accept return order RETURNED >> ??
  //(return_cancel) - picker,shipper,warehouse cancel return order RETURNED >> ??

  pickup,

  //// (6) - picker store order PICKED_UP >> WAREHOUSE --same1 --scan qr code of warehouse
  //*(7) - shipper deliver to customer SHIPPING >> DELIVERED
  //(8) - warehouse give order to customer WAREHOUSE >> DELIVERED
  deliver,
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
          //# (1) picker get order from shop
          return 'Lấy hàng';
        } else if ((transport.status == OrderStatus.PICKED_UP || transport.status == OrderStatus.SHIPPING) &&
            currentWorkType == TypeWork.WAREHOUSE) {
          //# (!2, 3, 3'1) warehouse get order from shop/picker/shipper
          //// transport.status == OrderStatus.PICKUP_PENDING ||
          return 'Lưu kho';
        } else if (transport.status == OrderStatus.WAREHOUSE && currentWorkType == TypeWork.SHIPPER) {
          //# (5) shipper get order from warehouse
          return 'Lấy hàng từ kho';
        } else if ((currentWorkType == TypeWork.PICKUP ||
                currentWorkType == TypeWork.SHIPPER ||
                currentWorkType == TypeWork.WAREHOUSE) &&
            transport.status == OrderStatus.RETURNED) {
          return 'Chấp nhận trả hàng';
        }

      case DeliveryType.deliver:
        if (transport.status == OrderStatus.PICKED_UP && currentWorkType == TypeWork.PICKUP) {
          return null;
        } else if (transport.status == OrderStatus.SHIPPING && currentWorkType == TypeWork.SHIPPER) {
          //# (7) shipper deliver to customer
          return 'Giao hàng thành công';
        } else if (transport.status == OrderStatus.WAREHOUSE && currentWorkType == TypeWork.WAREHOUSE) {
          //# (8) warehouse give order to customer WAREHOUSE >> DELIVERED
          return 'Giao tại kho thành công';
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
          //# (1) picker get order from shop
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
          //// transport.status == OrderStatus.PICKUP_PENDING ||
          //# (!2, 3, 3'1) warehouse get order from shop/picker/shipper
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
          //# (5) shipper get order from warehouse
          final warehouseWardCode = transport.transportHandles.first.wardCode;
          return () async => await execute(context, controller, () {
                return sl<DeliveryRepository>().updateStatusTransportByDeliver(
                  transport.transportId,
                  OrderStatus.SHIPPING,
                  true,
                  //? when shipper get order from warehouse, that order must be 'OrderStatus.WAREHOUSE'
                  //? so just get the wardCode from the first handle
                  warehouseWardCode,
                );
              });
        } else if (transport.status == OrderStatus.RETURNED &&
            (currentWorkType == TypeWork.PICKUP ||
                currentWorkType == TypeWork.SHIPPER ||
                currentWorkType == TypeWork.WAREHOUSE)) {
          //# (return_accept) - picker,shipper,warehouse accept return order RETURNED >> ??
          return () async => await execute(context, controller, () {
                return sl<DeliveryRepository>().acceptReturn(transport.transportId);
              });
        } else {
          return null;
        }

      case DeliveryType.deliver:
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
          //# (7) shipper deliver to customer
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
          //# (8) warehouse give order to customer WAREHOUSE >> DELIVERED
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
        }
        return null; // after all, return null --no action
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
