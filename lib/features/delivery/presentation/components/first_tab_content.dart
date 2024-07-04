import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import '../../../../app_state.dart';
import '../components/menu_action_item.dart';
import '../pages/delivery_scanner_page.dart';

//! json format for warehouse's qr
// {
//   'wU': warehouseUsername,
//   'wC': warehouseWardCode,
// }

const _menuLabelTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
const _cashLabelTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);

class FirstTabContent extends StatelessWidget {
  const FirstTabContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final TypeWork typeWork = Provider.of<AppState>(context).typeWork;
    return Stack(
      fit: StackFit.expand,
      children: [
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
                  return Row(
                    children: [
                      const SizedBox(width: 8),
                      MenuActionItem(
                        label: 'Đơn hàng\n gần đây',
                        icon: Icons.location_on_outlined,
                        color: Colors.orange,
                        size: 50,
                        labelTextStyle: _cashLabelTextStyle,
                        onPressed: () => Navigator.of(context).pushNamed('/pickup'),
                      ),
                    ],
                  );
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
        const SizedBox(width: 10),
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
        MenuActionItem(
          label: typeWork == TypeWork.WAREHOUSE ? 'Lưu kho / Lấy hàng' : 'Chuẩn bị giao',
          icon: Icons.qr_code_scanner,
          color: Colors.blue,
          labelTextStyle: _menuLabelTextStyle,
          onPressed: () async {
            await Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.pickup);
          },
        ),
        const SizedBox(width: 10),
        MenuActionItem(
          label: 'Giao hàng',
          icon: Icons.assignment_turned_in_outlined,
          color: Colors.green,
          labelTextStyle: _menuLabelTextStyle,
          onPressed: () async {
            await Navigator.of(context).pushNamed(DeliveryScannerPage.routeName, arguments: DeliveryType.deliver);
          },
        ),
      ],
    );
  }
}
