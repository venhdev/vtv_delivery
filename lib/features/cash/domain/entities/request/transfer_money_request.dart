// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class TransferMoneyRequest {
  final List<String> cashOrderIds;
  final String waveHouseUsername;

  const TransferMoneyRequest({
    required this.cashOrderIds,
    required this.waveHouseUsername,
  });

  @override
  String toString() => 'TransferMoneyRequest(cashOrderIds: $cashOrderIds, waveHouseUsername: $waveHouseUsername)';

  TransferMoneyRequest copyWith({
    List<String>? cashOrderIds,
    String? waveHouseUsername,
  }) {
    return TransferMoneyRequest(
      cashOrderIds: cashOrderIds ?? this.cashOrderIds,
      waveHouseUsername: waveHouseUsername ?? this.waveHouseUsername,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'cashOrderIds': cashOrderIds,
      'waveHouseUsername': waveHouseUsername,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  bool operator ==(covariant TransferMoneyRequest other) {
    if (identical(this, other)) return true;

    return listEquals(other.cashOrderIds, cashOrderIds) && other.waveHouseUsername == waveHouseUsername;
  }

  @override
  int get hashCode => cashOrderIds.hashCode ^ waveHouseUsername.hashCode;
}
