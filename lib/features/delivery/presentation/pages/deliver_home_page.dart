import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../dependency_container.dart';
import '../../domain/repository/deliver_repository.dart';
import '../components/menu_action_item.dart';

const title = 'Trang chủ';

class DeliverHomePage extends StatelessWidget {
  const DeliverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.message ?? 'Có lỗi xảy ra! Vui lòng thử lại!')),
            );
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          if (!state.auth!.userInfo.roles!.contains(Role.DELIVER)) {
            return NoPermissionPage(
              message: 'Bạn không có quyền truy cập vào ứng dụng này!',
              onPressed: () => context.read<AuthCubit>().logout(state.auth!.refreshToken),
            );
          }
          return const _HomePage();
        } else {
          return _noAuth(context);
        }
      },
    );
  }

  Widget _noAuth(BuildContext context) {
    return GestureDetector(
      onLongPress: () => Navigator.of(context).pushNamed('/dev'),
      child: LoginPage(
        showTitle: false,
        formTitle: 'VTV Delivery',
        onLoginPressed: (username, password) async {
          context.read<AuthCubit>().loginWithUsernameAndPassword(username: username, password: password);
        },
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

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
        title: const Text(title),
        centerTitle: true,
        actions: [
          //# Profile
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
      ),
    );
  }
}
