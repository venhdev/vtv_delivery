import 'package:delivery/features/cash/domain/repository/cash_repository.dart';
import 'package:delivery/features/delivery/domain/repository/delivery_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/profile.dart';

import '../../../../app_state.dart';
import '../../../../dependency_container.dart';
import '../../domain/entities/response/cash_order_detail_resp.dart';

class CashOrderDetailDialog extends StatelessWidget {
  const CashOrderDetailDialog({super.key, required this.cashOrderId});

  final String cashOrderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: sl<CashRepository>().getCashOrderDetailById(cashOrderId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final respEither = snapshot.data!;
            return respEither.fold(
              (error) => MessageScreen.error(error.message),
              (ok) => _build(context, ok.data!),
            );
          } else if (snapshot.hasError) {
            return MessageScreen.error(snapshot.error.toString());
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _build(BuildContext context, CashOrderDetailResp cashOrderDetail) {
    final typeWork = Provider.of<AppState>(context, listen: false).typeWork;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //# exit button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            //# order info
            Text('Thông tin đơn hàng', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            FlexibleList(
              list: {
                'Mã giao dịch': cashOrderDetail.cash.orderId,
                'Mã vận chuyển': cashOrderDetail.cash.transportId,
                'Trạng thái': (typeWork == TypeWork.WAREHOUSE)
                    ? cashOrderDetail.cash.statusNameByWarehouse
                    : cashOrderDetail.cash.statusNameByShipper,
                if (typeWork == TypeWork.WAREHOUSE) 'Shipper': cashOrderDetail.cash.shipperUsername,
                'Số tiền': ConversionUtils.formatCurrency(cashOrderDetail.cash.money),
                'Ngày tạo':
                    ConversionUtils.convertDateTimeToString(cashOrderDetail.cash.createAt, pattern: 'dd/MM/yyyy HH:mm'),
                'Ngày cập nhật':
                    ConversionUtils.convertDateTimeToString(cashOrderDetail.cash.updateAt, pattern: 'dd/MM/yyyy HH:mm'),
              },
              separatorBuilder: (_) => const Divider(thickness: 0.5, height: 8),
            ),

            //# shop info
            const Divider(color: Colors.black87),
            Text('Thông tin người bán', style: Theme.of(context).textTheme.labelLarge),
            FlexibleList(
              list: {
                'Tên cửa hàng': cashOrderDetail.order.shop.name,
                'Địa chỉ': cashOrderDetail.order.shop.fullAddress,
                'Số điện thoại': cashOrderDetail.order.shop.phone,
                'Email': cashOrderDetail.order.shop.email,
              },
              separatorBuilder: (_) => const Divider(thickness: 0.5, height: 8),
            ),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async => await LaunchUtils.openCallWithPhoneNumber(cashOrderDetail.order.shop.phone),
                  label: const Text('Gọi điện'),
                  icon: const Icon(Icons.phone),
                ),
                TextButton.icon(
                  onPressed: () async => await LaunchUtils.openMapWithQuery(cashOrderDetail.order.shop.fullAddress),
                  label: const Text('Mở bản đồ'),
                  icon: const Icon(Icons.location_on),
                ),
                TextButton.icon(
                  onPressed: () async =>
                      await LaunchUtils.openMapNavigationWithQuery(cashOrderDetail.order.shop.fullAddress),
                  label: const Text('Chỉ đường'),
                  icon: const Icon(Icons.directions),
                ),
              ],
            ),

            //# customer info
            const Divider(color: Colors.black87),
            Text('Thông tin khách hàng', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            DeliveryAddress(
              address: cashOrderDetail.order.address,
              suffixIcon: null,
              // onSuffixTap: () => LaunchUtils.openMapWithQuery(StringUtils.getAddress(cashOrderDetail.order.address)),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                TextButton.icon(
                  onPressed: () async => await LaunchUtils.openCallWithPhoneNumber(cashOrderDetail.order.address.phone),
                  label: const Text('Gọi điện'),
                  icon: const Icon(Icons.phone),
                ),
                TextButton.icon(
                  onPressed: () async =>
                      await LaunchUtils.openMapWithQuery(StringUtils.getAddress(cashOrderDetail.order.address)),
                  label: const Text('Mở bản đồ'),
                  icon: const Icon(Icons.location_on),
                ),
                TextButton.icon(
                  onPressed: () async => await LaunchUtils.openMapNavigationWithQuery(
                      StringUtils.getAddress(cashOrderDetail.order.address)),
                  label: const Text('Chỉ đường'),
                  icon: const Icon(Icons.directions),
                ),
              ],
            ),

            //# button delivery success
            if (typeWork == TypeWork.WAREHOUSE || typeWork == TypeWork.SHIPPER) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  // get transportId and then check if it's the same as the current order
                  final scannedTransportId = await Navigator.of(context).pushNamed('/scan') as String?;
                  if (scannedTransportId != null &&
                      context.mounted &&
                      cashOrderDetail.cash.transportId == scannedTransportId) {
                    // update status to DELIVERED
                    final resp = await showDialogToPerform(
                      context,
                      dataCallback: () => sl<DeliveryRepository>().updateStatusTransportByDeliver(
                        cashOrderDetail.cash.transportId,
                        OrderStatus.DELIVERED,
                        true,
                        cashOrderDetail.order.address.wardCode,
                      ),
                      closeBy: (context, result) => Navigator.of(context).pop(result),
                    );
                    if (resp != null) {
                      showToastResult(
                        resp,
                        successMsg: 'Giao hàng thành công',
                        onSuccess: () => Navigator.of(context).pop(), // pop this dialog
                      );
                    }
                  }
                },
                child: const Text('Giao hàng thành công'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
