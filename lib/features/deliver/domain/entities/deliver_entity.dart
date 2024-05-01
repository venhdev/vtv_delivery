// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'district_work_entity.dart';
import 'ward_work_entity.dart';

class DeliverEntity {
  final int deliverId;
  final String phone;
  final String provinceName;
  final String districtName;
  final String wardName;
  final String fullAddress;
  final String typeWork;
  final String usernameAdded;
  final String status;
  final String wardCode;
  final int customerId;
  final int transportProviderId;
  final String transportProviderShortName;
  final DistrictWorkEntity districtWork;
  final int countWardWork;
  final List<WardWorkEntity> wardWorks;

  DeliverEntity({
    required this.deliverId,
    required this.phone,
    required this.provinceName,
    required this.districtName,
    required this.wardName,
    required this.fullAddress,
    required this.typeWork,
    required this.usernameAdded,
    required this.status,
    required this.wardCode,
    required this.customerId,
    required this.transportProviderId,
    required this.transportProviderShortName,
    required this.districtWork,
    required this.countWardWork,
    required this.wardWorks,
  });

  DeliverEntity copyWith({
    int? deliverId,
    String? phone,
    String? provinceName,
    String? districtName,
    String? wardName,
    String? fullAddress,
    String? typeWork,
    String? usernameAdded,
    String? status,
    String? wardCode,
    int? customerId,
    int? transportProviderId,
    String? transportProviderShortName,
    DistrictWorkEntity? districtWork,
    int? countWardWork,
    List<WardWorkEntity>? wardWorks,
  }) {
    return DeliverEntity(
      deliverId: deliverId ?? this.deliverId,
      phone: phone ?? this.phone,
      provinceName: provinceName ?? this.provinceName,
      districtName: districtName ?? this.districtName,
      wardName: wardName ?? this.wardName,
      fullAddress: fullAddress ?? this.fullAddress,
      typeWork: typeWork ?? this.typeWork,
      usernameAdded: usernameAdded ?? this.usernameAdded,
      status: status ?? this.status,
      wardCode: wardCode ?? this.wardCode,
      customerId: customerId ?? this.customerId,
      transportProviderId: transportProviderId ?? this.transportProviderId,
      transportProviderShortName: transportProviderShortName ?? this.transportProviderShortName,
      districtWork: districtWork ?? this.districtWork,
      countWardWork: countWardWork ?? this.countWardWork,
      wardWorks: wardWorks ?? this.wardWorks,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deliverId': deliverId,
      'phone': phone,
      'provinceName': provinceName,
      'districtName': districtName,
      'wardName': wardName,
      'fullAddress': fullAddress,
      'typeWork': typeWork,
      'usernameAdded': usernameAdded,
      'status': status,
      'wardCode': wardCode,
      'customerId': customerId,
      'transportProviderId': transportProviderId,
      'transportProviderShortName': transportProviderShortName,
      'districtWork': districtWork.toMap(),
      'countWardWork': countWardWork,
      'wardsWork': wardWorks.map((x) => x.toMap()).toList(),
    };
  }

  factory DeliverEntity.fromMap(Map<String, dynamic> map) {
    return DeliverEntity(
      deliverId: map['deliverId'] as int,
      phone: map['phone'] as String,
      provinceName: map['provinceName'] as String,
      districtName: map['districtName'] as String,
      wardName: map['wardName'] as String,
      fullAddress: map['fullAddress'] as String,
      typeWork: map['typeWork'] as String,
      usernameAdded: map['usernameAdded'] as String,
      status: map['status'] as String,
      wardCode: map['wardCode'] as String,
      customerId: map['customerId'] as int,
      transportProviderId: map['transportProviderId'] as int,
      transportProviderShortName: map['transportProviderShortName'] as String,
      districtWork: DistrictWorkEntity.fromMap(map['districtWork'] as Map<String, dynamic>),
      countWardWork: map['countWardWork'] as int,
      wardWorks: List<WardWorkEntity>.from(
        (map['wardsWork'] as List).map<WardWorkEntity>(
          (x) => WardWorkEntity.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory DeliverEntity.fromJson(String source) => DeliverEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DeliverEntity(deliverId: $deliverId, phone: $phone, provinceName: $provinceName, districtName: $districtName, wardName: $wardName, fullAddress: $fullAddress, typeWork: $typeWork, usernameAdded: $usernameAdded, status: $status, wardCode: $wardCode, customerId: $customerId, transportProviderId: $transportProviderId, transportProviderShortName: $transportProviderShortName, districtWork: $districtWork, countWardWork: $countWardWork, wardsWork: $wardWorks)';
  }

  @override
  bool operator ==(covariant DeliverEntity other) {
    if (identical(this, other)) return true;

    return other.deliverId == deliverId &&
        other.phone == phone &&
        other.provinceName == provinceName &&
        other.districtName == districtName &&
        other.wardName == wardName &&
        other.fullAddress == fullAddress &&
        other.typeWork == typeWork &&
        other.usernameAdded == usernameAdded &&
        other.status == status &&
        other.wardCode == wardCode &&
        other.customerId == customerId &&
        other.transportProviderId == transportProviderId &&
        other.transportProviderShortName == transportProviderShortName &&
        other.districtWork == districtWork &&
        other.countWardWork == countWardWork &&
        listEquals(other.wardWorks, wardWorks);
  }

  @override
  int get hashCode {
    return deliverId.hashCode ^
        phone.hashCode ^
        provinceName.hashCode ^
        districtName.hashCode ^
        wardName.hashCode ^
        fullAddress.hashCode ^
        typeWork.hashCode ^
        usernameAdded.hashCode ^
        status.hashCode ^
        wardCode.hashCode ^
        customerId.hashCode ^
        transportProviderId.hashCode ^
        transportProviderShortName.hashCode ^
        districtWork.hashCode ^
        countWardWork.hashCode ^
        wardWorks.hashCode;
  }
}
