import 'package:flutter/widgets.dart';
import 'package:vtv_common/core.dart';

import '../../domain/entities/cash_order_entity.dart';

class CashItem extends StatelessWidget {
  const CashItem({super.key, required this.cash});

  final CashOrderEntity cash;

  @override
  Widget build(BuildContext context) {
    return ListDynamic(list: {
      'Mã giao dịch': cash.orderId,
      'Mã vận chuyển': cash.transportId,
      'Trạng thái': cash.statusNameByShipper,
      'Số tiền': ConversionUtils.formatCurrency(cash.money),
      'Ngày tạo': ConversionUtils.convertDateTimeToString(cash.createAt),
      'Ngày cập nhật': ConversionUtils.convertDateTimeToString(cash.updateAt),
    });
  }
}
