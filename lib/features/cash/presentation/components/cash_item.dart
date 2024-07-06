import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/guest.dart';
import 'package:vtv_common/profile.dart';

import '../../../../dependency_container.dart';
import '../../../delivery/domain/repository/delivery_repository.dart';
import '../../domain/entities/cash_order_entity.dart';

class CashItem extends StatelessWidget {
  const CashItem({super.key, required this.cash, required this.isWarehouse, this.onPressed, required this.showAddress});

  final CashOrderEntity cash;
  final bool isWarehouse;
  final VoidCallback? onPressed;
  final bool showAddress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        // margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: FlexibleList(
          list: {
            'Mã giao dịch': cash.orderId,
            'Mã vận chuyển': cash.transportId,
            'Trạng thái': isWarehouse ? cash.statusNameByWarehouse : cash.statusNameByShipper,
            if (isWarehouse) 'Shipper': cash.shipperUsername,
            'Số tiền': ConversionUtils.formatCurrency(cash.money),
            'Ngày tạo': ConversionUtils.convertDateTimeToString(cash.createAt, pattern: 'dd/MM/yyyy HH:mm'),
            'Ngày cập nhật': ConversionUtils.convertDateTimeToString(cash.updateAt, pattern: 'dd/MM/yyyy HH:mm'),
          },
          separatorBuilder: (_) => const Divider(thickness: 0.5, height: 8),
          bottomBuilder: showAddress
              ? (context) {
                  return Column(
                    children: [
                      const Divider(thickness: 0.5, height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: FutureBuilder(
                              future: sl<DeliveryRepository>().getCustomerWardCodeByTransportId(cash.transportId),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data!.fold(
                                    (error) => MessageScreen.error(error.message),
                                    (ok) => AddressByWardCode(
                                      futureData: sl<GuestRepository>().getAddressByWardCode(ok.data!),
                                      prefix: 'Địa chỉ: ',
                                      showDirection: true,
                                    ),
                                  );
                                }
                                return const Text(
                                  'Đang tải địa chỉ...',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              : null,
        ),
      ),
    );
  }
}
