import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';

import '../../domain/entities/cash_order_entity.dart';

class CashItem extends StatelessWidget {
  const CashItem({super.key, required this.cash});

  final CashOrderEntity cash;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ListDynamic(
        list: {
          'Mã giao dịch': cash.orderId,
          'Mã vận chuyển': cash.transportId,
          'Trạng thái': cash.statusNameByShipper,
          'Số tiền': ConversionUtils.formatCurrency(cash.money),
          'Ngày tạo': ConversionUtils.convertDateTimeToString(cash.createAt),
          'Ngày cập nhật': ConversionUtils.convertDateTimeToString(cash.updateAt),
        },
        separatorBuilder: (_) => const Divider(thickness: 0.5, height: 8),
      ),
    );
  }
}
