import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/repository/deliver_repository.dart';
import '../components/menu_action_item.dart';

class HomePageContent extends StatelessWidget {
  const HomePageContent({
    super.key,
  });

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
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          //# menu actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MenuActionItem(
                label: 'Lấy hàng',
                icon: Icons.qr_code_scanner,
                color: Colors.blue,
                onPressed: () async {
                  var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
                  if (transportOrderId != null && context.mounted) _handleScannedPickup(context, transportOrderId);
                },
              ),
              const SizedBox(width: 10),
              MenuActionItem(
                label: 'Giao hàng',
                icon: Icons.delivery_dining,
                color: Colors.green,
                onPressed: () async {
                  var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
                  if (transportOrderId != null && context.mounted) _handleScannedDelivered(context, transportOrderId);
                },
              ),
            ],
          ),

          //# view nearby orders
          IconTextButton(
            onPressed: () => Navigator.of(context).pushNamed('/pickup'),
            label: 'Xem đơn hàng gần đây',
            leadingIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }
}
