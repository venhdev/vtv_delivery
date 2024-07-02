import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/guest.dart';
import 'package:vtv_common/order.dart';
import 'package:vtv_common/profile.dart';

import '../../../../dependency_container.dart';

class TransportInfo extends StatelessWidget {
  const TransportInfo({
    super.key,
    required this.transport,
    required this.onReScan,
    required this.onConfirm,
    this.confirmLabel,
    this.reScanLabel,
  });
  final TransportEntity transport;

  final VoidCallback? onReScan;
  final VoidCallback? onConfirm;

  final String? confirmLabel;
  final String? reScanLabel;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Colors.white60,
    );

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white12,
        border: Border.all(color: Colors.white60),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              'Thông tin đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white60),
            ),
          ),
          Text(
            'Mã đơn hàng: ${transport.orderId}',
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Mã vận đơn: ${transport.transportId}',
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
          Text('Phương thức vận chuyển: ${transport.shippingMethod}', style: textStyle),
          Text('Trạng thái: ${StringUtils.getOrderStatusName(transport.status)}', style: textStyle),

          AddressByWardCode(
              futureData: sl<GuestRepository>().getAddressByWardCode(transport.wardCodeShop),
              prefix: 'Địa chỉ shop: (${transport.wardCodeShop}) ',
              style: textStyle),

          AddressByWardCode(
              futureData: sl<GuestRepository>().getAddressByWardCode(transport.wardCodeCustomer),
              prefix: 'Địa chỉ khách hàng: (${transport.wardCodeCustomer}) ',
              style: textStyle),

          //# actions: cancel, re-scan, confirm and re-scan
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: onReScan,
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.blue.shade100)),
                child: Text(reScanLabel ?? 'Quét lại'),
              ),
              const SizedBox(width: 8),
              if (onConfirm != null)
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ButtonStyle(backgroundColor: WidgetStateProperty.all(Colors.green.shade100)),
                  child: Text(confirmLabel ?? 'Xác nhận'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
