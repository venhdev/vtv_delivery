import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vtv_common/core.dart';

import '../../../../service_locator.dart';
import '../../domain/repository/deliver_repository.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  void _handleScannedPickup(BuildContext context, String transportOrderId) {
    showDialogToConfirm(
      context: context,
      title: 'Đã lấy kiện hàng ở Shop?',
      content: 'Mã đơn hàng: $transportOrderId',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
      onConfirm: () async {
        final respEither = await sl<DeliverRepository>().updateStatusTransportByDeliver(
          transportOrderId,
          OrderStatus.PICKED_UP,
          true,
          '11500', //TODO: implement real location
        );

        respEither.fold(
          (error) => Fluttertoast.showToast(msg: error.message ?? 'Có lỗi xảy ra khi cập nhật trạng thái đơn hàng!'),
          (ok) {
            Fluttertoast.showToast(msg: 'Đã nhận đơn hàng thành công!');
          },
        );
      },
    );
  }

  void _handleScannedDelivered(BuildContext context, String transportOrderId) {
    showDialogToConfirm(
      context: context,
      title: 'Đã giao hàng thành công?',
      content: 'Mã đơn hàng: $transportOrderId',
      confirmText: 'Xác nhận',
      dismissText: 'Thoát',
      onConfirm: () async {
        final respEither = await sl<DeliverRepository>().updateStatusTransportByDeliver(
          transportOrderId,
          OrderStatus.DELIVERED,
          true,
          '11500', //TODO: implement real location
        );

        respEither.fold(
          (error) => Fluttertoast.showToast(msg: error.message ?? 'Có lỗi xảy ra khi cập nhật trạng thái đơn hàng!'),
          (ok) {
            Fluttertoast.showToast(msg: 'Đã giao thành công!');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              var deliver = await sl<DeliverRepository>().getDeliverInfo();
              deliver.fold(
                (error) => null,
                (ok) => Navigator.of(context).pushNamed(
                  '/profile',
                  arguments: ok.data!,
                ),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MenuItem(
                  label: 'Lấy hàng',
                  icon: Icons.qr_code_scanner,
                  color: Colors.blue,
                  onPressed: () async {
                    var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
                    // log('transportOrderId: $transportOrderId');
                    if (transportOrderId != null && context.mounted) _handleScannedPickup(context, transportOrderId);
                  },
                ),
                const SizedBox(width: 10),
                MenuItem(
                  label: 'Giao hàng',
                  icon: Icons.delivery_dining,
                  color: Colors.green,
                  onPressed: () async {
                    var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
                    // log('transportOrderId: $transportOrderId');
                    if (transportOrderId != null && context.mounted) _handleScannedDelivered(context, transportOrderId);
                  },
                ),
              ],
            ),
            // view nearby orders
            IconTextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/pickup');
              },
              label: 'Xem đơn hàng gần đây',
              leadingIcon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({super.key, required this.label, required this.icon, this.color, this.onPressed});

  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        padding: const EdgeInsets.all(8),
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            Text(label),
          ],
        ),
      ),
    );
  }
}
