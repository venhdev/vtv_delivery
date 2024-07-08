import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../app_state.dart';
import '../components/menu_action_item.dart';
import 'delivery_scanner_page.dart';

//! json format for warehouse's qr
// {
//   'wU': warehouseUsername,
//   'wC': warehouseWardCode,
// }

const _menuLabelTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
const _cashLabelTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

class DeliveryHomePage extends StatelessWidget {
  const DeliveryHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TypeWork typeWork = Provider.of<AppState>(context).typeWork;
    return Stack(
      fit: StackFit.expand,
      children: [
        // if (typeWork == TypeWork.WAREHOUSE) Align(alignment: Alignment.topCenter, child: _warehouseQrCode()),
        //# app bar actions
        Align(
          alignment: Alignment.topLeft,
          child: IntrinsicHeight(
            child: Builder(
              builder: (context) {
                if (typeWork == TypeWork.WAREHOUSE) {
                  return _warehouseAppBar(context);
                } else if (typeWork == TypeWork.PICKUP) {
                  //# view nearby orders
                  return _pickupAppBar(context);
                } else if (typeWork == TypeWork.SHIPPER) {
                  //# view nearby orders
                  return _shipperAppBar(context);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),

        //# menu actions
        Align(
          alignment: Alignment.center,
          child: IntrinsicHeight(
            child: Builder(builder: (context) {
              if (typeWork == TypeWork.SHIPPER || typeWork == TypeWork.WAREHOUSE) {
                return _shipperAndWarehouseActions(context, typeWork);
              } else if (typeWork == TypeWork.PICKUP) {
                return _pickupActions(context);
              }
              return const SizedBox.shrink();
            }),
          ),
        ),
      ],
    );
  }

  // Builder _warehouseQrCode() {
  //   return Builder(builder: (context) {
  //     final warehouseUsername = context.read<AuthCubit>().state.currentUsername;
  //     final warehouseWardCode = Provider.of<AppState>(context, listen: false).deliveryInfo!.wardCode;
  //     return Column(
  //       children: [
  //         Container(
  //           decoration: BoxDecoration(
  //             color: Colors.orange.shade100,
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(color: Colors.orange.shade300),
  //           ),
  //           child: QrView(
  //             data: jsonEncode({
  //               'wU': warehouseUsername,
  //               'wC': warehouseWardCode,
  //             }),
  //             size: 150,
  //           ),
  //         ),
  //         const Text('QR của kho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //       ],
  //     );
  //   });
  // }

  Row _pickupAppBar(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        MenuActionItem(
          label: 'Đơn hàng\ngần đây',
          icon: Icons.location_on_outlined,
          color: Colors.orange,
          size: 50,
          labelTextStyle: _cashLabelTextStyle,
          onPressed: () => Navigator.of(context).pushNamed('/pickup'),
        ),
        const SizedBox(width: 16),
        MenuActionItem(
          label: 'Trả hàng',
          icon: Icons.qr_code_scanner,
          color: Colors.redAccent,
          size: 50,
          labelTextStyle: _cashLabelTextStyle,
          onPressed: () {
            Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.pickup);
          },
        ),
      ],
    );
  }

  Row _shipperAppBar(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 16),
        MenuActionItem(
          label: 'Trả hàng',
          icon: Icons.qr_code_scanner,
          color: Colors.redAccent,
          size: 50,
          labelTextStyle: _cashLabelTextStyle,
          onPressed: () {
            Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.pickup);
          },
        ),
      ],
    );
  }

  Widget _pickupActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //# open scanner to get order's qr >> pickup then deliver to warehouse
        MenuActionItem(
          label: 'Lấy hàng',
          icon: Icons.qr_code,
          color: Colors.blue,
          labelTextStyle: _menuLabelTextStyle,
          onPressed: () async {
            await Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.pickup);
          },
        ),
        // const SizedBox(width: 8),

        // //# open scanner to get warehouse's qr >> delivered to warehouse
        // MenuActionItem(
        //   label: 'Lưu kho',
        //   icon: Icons.mode_of_travel_outlined,
        //   color: Colors.green,
        //   labelTextStyle: _menuLabelTextStyle,
        //   onPressed: () async {
        //     final warehouseUsername = context.read<AuthCubit>().state.currentUsername;
        //     Navigator.of(context).pushNamed('/qr', arguments: warehouseUsername);
        //   },
        // ),
      ],
    );
  }

  Row _warehouseAppBar(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 16),
        //# warehouse's qr
        MenuActionItem(
          label: 'QR của kho',
          icon: Icons.qr_code,
          color: Colors.orange,
          size: 50,
          labelTextStyle: _cashLabelTextStyle,
          onPressed: () async {
            final warehouseUsername = context.read<AuthCubit>().state.currentUsername;
            final warehouseWardCode = Provider.of<AppState>(context, listen: false).deliveryInfo!.wardCode;
            final data = jsonEncode({
              'wU': warehouseUsername,
              'wC': warehouseWardCode,
            });
            Navigator.of(context).pushNamed('/qr', arguments: data);
          },
        ),

        const SizedBox(width: 16),
        MenuActionItem(
          label: 'Trả hàng',
          icon: Icons.qr_code_scanner,
          color: Colors.cyan,
          size: 50,
          labelTextStyle: _cashLabelTextStyle,
          onPressed: () {
            Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.pickup);
          },
        ),

        // //# view nearby orders
        // const SizedBox(width: 10),
        // MenuActionItem(
        //   label: 'Đơn hàng\n gần đây',
        //   icon: Icons.location_on_outlined,
        //   color: Colors.orange,
        //   size: 50,
        //   labelTextStyle: _cashLabelTextStyle,
        //   onPressed: () => Navigator.of(context).pushNamed('/pickup'),
        // ),
      ],
    );
  }

  Row _shipperAndWarehouseActions(BuildContext context, TypeWork typeWork) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: typeWork == TypeWork.WAREHOUSE
              ? 'Lưu kho đơn hàng từ người lấy hàng / shop'
              : 'Lấy hàng từ kho để chuẩn bị giao',
          child: MenuActionItem(
            label: typeWork == TypeWork.WAREHOUSE ? 'Lưu kho / Nhận hàng' : 'Lấy hàng từ kho',
            icon: Icons.qr_code_scanner,
            color: Colors.blue,
            labelTextStyle: _menuLabelTextStyle,
            onPressed: () async {
              await Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.pickup);
            },
          ),
        ),
        const SizedBox(width: 10),
        Tooltip(
          message: 'Giao hàng cho khách',
          child: MenuActionItem(
            label: 'Giao cho khách',
            icon: Icons.assignment_turned_in_outlined,
            color: Colors.green,
            labelTextStyle: _menuLabelTextStyle,
            onPressed: () async {
              await Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.deliver);
            },
          ),
        ),
      ],
    );
  }
}
