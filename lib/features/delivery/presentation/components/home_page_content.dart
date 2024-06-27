import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../app_state.dart';
import '../../../../dependency_container.dart';
import '../../domain/repository/delivery_repository.dart';
import '../components/menu_action_item.dart';

const _menuLabelTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
const _cashLabelTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

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
        final respEither = await sl<DeliveryRepository>().updateStatusTransportByDeliver(
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
        final respEither = await sl<DeliveryRepository>().updateStatusTransportByDeliver(
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
    return Stack(
      // crossAxisAlignment: CrossAxisAlignment.center,
      // mainAxisAlignment: MainAxisAlignment.center,
      // mainAxisSize: MainAxisSize.max,
      fit: StackFit.expand,
      children: [
        //# menu actions for cash
        _cashActions(),

        //# menu actions for delivery
        Align(
          alignment: Alignment.center,
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                MenuActionItem(
                  label: 'Lấy hàng',
                  icon: Icons.qr_code_scanner,
                  color: Colors.blue,
                  labelTextStyle: _menuLabelTextStyle,
                  onPressed: () async {
                    var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
                    if (transportOrderId != null && context.mounted) _handleScannedPickup(context, transportOrderId);
                  },
                ),
                const SizedBox(width: 10),
                MenuActionItem(
                  label: 'Giao hàng',
                  icon: Icons.assignment_turned_in_outlined,
                  color: Colors.green,
                  labelTextStyle: _menuLabelTextStyle,
                  onPressed: () async {
                    var transportOrderId = await Navigator.of(context).pushNamed('/scan') as String?;
                    if (transportOrderId != null && context.mounted) _handleScannedDelivered(context, transportOrderId);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Consumer<AppState> _cashActions() {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (state.typeWork == TypeWork.WAREHOUSE) {
          return Align(
            alignment: Alignment.topLeft,
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 10),
                  //# warehouse's qr
                  MenuActionItem(
                    label: 'QR của tôi',
                    icon: Icons.qr_code,
                    color: Colors.orange,
                    size: 50,
                    labelTextStyle: _cashLabelTextStyle,
                    onPressed: () async {
                      final warehouseUsername = context.read<AuthCubit>().state.currentUsername;
                      Navigator.of(context).pushNamed('/qr', arguments: warehouseUsername);
                    },
                  ),

                  //# view nearby orders
                  const SizedBox(width: 10),
                  MenuActionItem(
                    label: 'Đơn hàng\n gần đây',
                    icon: Icons.location_on_outlined,
                    color: Colors.orange,
                    size: 50,
                    labelTextStyle: _cashLabelTextStyle,
                    onPressed: () => Navigator.of(context).pushNamed('/pickup'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
