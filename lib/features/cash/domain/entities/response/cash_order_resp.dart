// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../cash_order_entity.dart';

class CashOrderResp extends Equatable {
  final int count;
  final int totalMoney;
  final List<CashOrderEntity> cashOrders;

  const CashOrderResp({
    required this.count,
    required this.totalMoney,
    required this.cashOrders,
  });

  @override
  List<Object> get props => [count, totalMoney, cashOrders];

  CashOrderResp copyWith({
    int? count,
    int? totalMoney,
    List<CashOrderEntity>? cashOrders,
  }) {
    return CashOrderResp(
      count: count ?? this.count,
      totalMoney: totalMoney ?? this.totalMoney,
      cashOrders: cashOrders ?? this.cashOrders,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'count': count,
      'totalMoney': totalMoney,
      'cashOrderDTOs': cashOrders.map((x) => x.toMap()).toList(),
    };
  }

  factory CashOrderResp.fromMap(Map<String, dynamic> map) {
    return CashOrderResp(
      count: map['count'] as int,
      totalMoney: map['totalMoney'] as int,
      cashOrders: List<CashOrderEntity>.from(
        (map['cashOrderDTOs'] as List).map<CashOrderEntity>(
          (x) => CashOrderEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CashOrderResp.fromJson(String source) => CashOrderResp.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;
}
