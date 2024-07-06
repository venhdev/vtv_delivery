// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:vtv_common/order.dart';

import '../cash_order_entity.dart';

class CashOrderDetailResp {
  final CashOrderEntity cash;
  final OrderEntity order;

  CashOrderDetailResp({
    required this.cash,
    required this.order,
  });

  CashOrderDetailResp copyWith({
    CashOrderEntity? cash,
    OrderEntity? order,
  }) {
    return CashOrderDetailResp(
      cash: cash ?? this.cash,
      order: order ?? this.order,
    );
  }

  // Map<String, dynamic> toMap() {
  //   return <String, dynamic>{
  //     'cashOrderDTO': cashOrder.toMap(),
  //     'orderDTO': order.toMap(),
  //   };
  // }

  factory CashOrderDetailResp.fromMap(Map<String, dynamic> map) {
    return CashOrderDetailResp(
      cash: CashOrderEntity.fromMap(map['cashOrderDTO'] as Map<String, dynamic>),
      order: OrderEntity.fromMap(map['orderDTO'] as Map<String, dynamic>),
    );
  }

  // String toJson() => json.encode(toMap());

  factory CashOrderDetailResp.fromJson(String source) =>
      CashOrderDetailResp.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CashOrderDetailResp(cashOrder: $cash, order: $order)';

  @override
  bool operator ==(covariant CashOrderDetailResp other) {
    if (identical(this, other)) return true;

    return other.cash == cash && other.order == order;
  }

  @override
  int get hashCode => cash.hashCode ^ order.hashCode;
}
