import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/guest.dart';
import 'package:vtv_common/order.dart';
import 'package:vtv_common/shop.dart';

import '../../../../dependency_container.dart';
import '../../domain/entities/shop_and_transport_entity.dart';
import '../../domain/entities/ward_work_entity.dart';
import '../../domain/repository/delivery_repository.dart';

class PickupPendingOrdersByWard extends StatelessWidget {
  const PickupPendingOrdersByWard({super.key, this.wardWork});

  final WardWorkEntity? wardWork; // if null, get by current ward work

  bool isEmpty(List<ShopAndTransportEntity> shopAndTransports) {
    for (final shopAndTransport in shopAndTransports) {
      if (shopAndTransport.count > 0) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: wardWork != null
          ? sl<DeliveryRepository>().getTransportByWardCode(wardWork!.wardCode)
          : sl<DeliveryRepository>().getTransportByWardWork(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (error) => MessageScreen.error(error.message),
            (ok) {
              if (ok.data!.shopAndTransports.isEmpty || isEmpty(ok.data!.shopAndTransports)) {
                return const Center(child: MessageScreen(message: 'Không có đơn hàng nào cần giao tại khu vực này!'));
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    for (final shopAndTransport in ok.data!.shopAndTransports)
                      if (shopAndTransport.count > 0) ShopAndTransport(shopAndTransport: shopAndTransport),
                  ],
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ShopAndTransport extends StatelessWidget {
  const ShopAndTransport({super.key, required this.shopAndTransport});

  final ShopAndTransportEntity shopAndTransport;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShopInfo(
          shopId: shopAndTransport.shop.shopId,
          shopName: shopAndTransport.shop.name,
          shopAvatar: shopAndTransport.shop.avatar,
          trailing: Text('Số đơn hàng: ${shopAndTransport.count}'),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          bottom: Row(
            children: [
              Expanded(
                child: Text(
                  'Địa chỉ Shop: ${shopAndTransport.shop.address}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              // open map
              IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  MapUtils.openMapWithQuery(shopAndTransport.shop.address);
                },
              ),
            ],
          ),
        ),
        for (final transport in shopAndTransport.transports) TransportItem(transport: transport),
      ],
    );
  }
}

class TransportItem extends StatelessWidget {
  const TransportItem({super.key, required this.transport});

  final TransportEntity transport;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiaryContainer),
        borderRadius: BorderRadius.circular(8),
      ),
      child: FutureBuilder(
          future: sl<GuestRepository>().getAddressByWardCode(transport.wardCodeCustomer),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              return snapshot.data!.fold(
                (error) => MessageScreen.error(error.message),
                (ok) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildStatus(transport.transportHandles.first.transportStatus),
                    Text('Mã đơn hàng: ${transport.orderId}', softWrap: false, overflow: TextOverflow.ellipsis),
                    // FullAddressByWardCode(
                    //   prefixString: 'Địa chỉ giao hàng: ',
                    //   wardCode: transport.wardCodeCustomer,
                    //   style: const TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    Text(
                      '${'Địa chỉ giao hàng: '}${ok.data!}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                    ),
                  ],
                ),
              );
            } else {
              return const Text(
                'Đang tải địa chỉ...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              );
            }
          }),
    );
  }

  Widget buildStatus(OrderStatus status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Trạng thái:'),
        OrderStatusBadge(status: status, type: OrderStatusBadgeType.shipper),
      ],
    );
  }
}

class FullAddressByWardCode extends StatelessWidget {
  const FullAddressByWardCode({super.key, required this.wardCode, this.prefixString, this.style});

  final String wardCode;
  final String? prefixString;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<GuestRepository>().getAddressByWardCode(wardCode),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!.fold(
            (error) => MessageScreen.error(error.message),
            (ok) => Text(
              '${prefixString ?? ''}${ok.data!}',
              style: style,
              maxLines: 2,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
