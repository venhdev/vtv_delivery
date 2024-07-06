import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';

import '../../domain/entities/response/cash_order_by_date_resp.dart';

class SummaryCashOnDate extends StatelessWidget {
  const SummaryCashOnDate({
    super.key,
    required this.cashOnDate,
    this.endBuilder,
  });

  final CashOrderByDateResp cashOnDate;
  final WidgetBuilder? endBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      color: Colors.blueGrey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: FlexibleList(list: {
                'Ngày': ConversionUtils.convertDateTimeToString(cashOnDate.date),
                'Tổng số đơn': cashOnDate.cashOrders.length.toString(),
                'Tổng tiền thu': ConversionUtils.formatCurrency(cashOnDate.totalMoney),
              }),
            ),
            if (endBuilder != null) ...[const SizedBox(width: 8), endBuilder!(context)],
          ],
        ),
      ),
    );
  }
}
