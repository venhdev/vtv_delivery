// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../shop_and_transport_entity.dart';
import '../ward_work_entity.dart';

class TransportResp {
  final int countShop;
  final int countTransport;
  final int countWard;
  final List<WardWorkEntity> wardWorks;
  final List<ShopAndTransportEntity> shopAndTransports;

  TransportResp({
    required this.countShop,
    required this.countTransport,
    required this.countWard,
    required this.wardWorks,
    required this.shopAndTransports,
  });

  TransportResp copyWith({
    int? countShop,
    int? countTransport,
    int? countWard,
    List<WardWorkEntity>? wardWorks,
    List<ShopAndTransportEntity>? shopAndTransports,
  }) {
    return TransportResp(
      countShop: countShop ?? this.countShop,
      countTransport: countTransport ?? this.countTransport,
      countWard: countWard ?? this.countWard,
      wardWorks: wardWorks ?? this.wardWorks,
      shopAndTransports: shopAndTransports ?? this.shopAndTransports,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'countShop': countShop,
      'countTransport': countTransport,
      'countWard': countWard,
      'wardWorks': wardWorks.map((x) => x.toMap()).toList(),
      'shopAndTransports': shopAndTransports.map((x) => x.toMap()).toList(),
    };
  }

  factory TransportResp.fromMap(Map<String, dynamic> map) {
    return TransportResp(
      countShop: map['countShop'] as int,
      countTransport: map['countTransport'] as int,
      countWard: map['countWard'] as int,
      wardWorks: List<WardWorkEntity>.from(
        (map['wardDTOs'] as List).map<WardWorkEntity>(
          (x) => WardWorkEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
      shopAndTransports: List<ShopAndTransportEntity>.from(
        (map['shopAndTransportsDTOs'] as List).map<ShopAndTransportEntity>(
          (x) => ShopAndTransportEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory TransportResp.fromJson(String source) => TransportResp.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TransportResp(countShop: $countShop, countTransport: $countTransport, countWard: $countWard, wardWorks: $wardWorks, shopAndTransports: $shopAndTransports)';
  }

  @override
  bool operator ==(covariant TransportResp other) {
    if (identical(this, other)) return true;

    return other.countShop == countShop &&
        other.countTransport == countTransport &&
        other.countWard == countWard &&
        listEquals(other.wardWorks, wardWorks) &&
        listEquals(other.shopAndTransports, shopAndTransports);
  }

  @override
  int get hashCode {
    return countShop.hashCode ^
        countTransport.hashCode ^
        countWard.hashCode ^
        wardWorks.hashCode ^
        shopAndTransports.hashCode;
  }
}
