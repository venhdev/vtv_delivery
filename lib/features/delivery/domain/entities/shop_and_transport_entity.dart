// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vtv_common/order.dart';
import 'package:vtv_common/shop.dart';

class ShopAndTransportEntity {
  final int count;
  final String wardCode;
  final String wardName;
  final ShopEntity shop;
  final List<TransportEntity> transports;

  ShopAndTransportEntity({
    required this.count,
    required this.wardCode,
    required this.wardName,
    required this.shop,
    required this.transports,
  });

  ShopAndTransportEntity copyWith({
    int? count,
    String? wardCode,
    String? wardName,
    ShopEntity? shop,
    List<TransportEntity>? transports,
  }) {
    return ShopAndTransportEntity(
      count: count ?? this.count,
      wardCode: wardCode ?? this.wardCode,
      wardName: wardName ?? this.wardName,
      shop: shop ?? this.shop,
      transports: transports ?? this.transports,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'count': count,
      'wardCode': wardCode,
      'wardName': wardName,
      'shop': shop.toMap(),
      'transports': transports.map((x) => x.toMap()).toList(),
    };
  }

  factory ShopAndTransportEntity.fromMap(Map<String, dynamic> map) {
    return ShopAndTransportEntity(
      count: map['count'] as int,
      wardCode: map['wardCode'] as String,
      wardName: map['wardName'] as String,
      shop: ShopEntity.fromMap(map['shopDTO'] as Map<String, dynamic>),
      transports: List<TransportEntity>.from(
        (map['transportDTOs'] as List).map<TransportEntity>(
          (x) => TransportEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ShopAndTransportEntity.fromJson(String source) =>
      ShopAndTransportEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ShopAndTransportEntity(count: $count, wardCode: $wardCode, wardName: $wardName, shop: $shop, transports: $transports)';
  }

  @override
  bool operator ==(covariant ShopAndTransportEntity other) {
    if (identical(this, other)) return true;

    return other.count == count &&
        other.wardCode == wardCode &&
        other.wardName == wardName &&
        other.shop == shop &&
        listEquals(other.transports, transports);
  }

  @override
  int get hashCode {
    return count.hashCode ^ wardCode.hashCode ^ wardName.hashCode ^ shop.hashCode ^ transports.hashCode;
  }
}
