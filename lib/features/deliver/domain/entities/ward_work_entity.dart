// import 'dart:convert';
import 'package:vtv_common/profile.dart';

class WardWorkEntity extends WardEntity {
  const WardWorkEntity({
    required super.wardCode,
    required super.name,
    required super.fullName,
    required super.administrativeUnitShortName,
  });

  factory WardWorkEntity.fromMap(Map<String, dynamic> data) => WardWorkEntity(
        wardCode: data['wardCode'] as String,
        name: data['name'] as String,
        fullName: data['fullName'] as String,
        administrativeUnitShortName: data['administrativeUnitShortName'] as String,
      );
}
// class WardWorkEntity {
//   final String wardCode;
//   final String name;
//   final String fullName;
//   final String administrativeUnitShortName;

//   WardWorkEntity({
//     required this.wardCode,
//     required this.name,
//     required this.fullName,
//     required this.administrativeUnitShortName,
//   });

//   WardWorkEntity copyWith({
//     String? wardCode,
//     String? name,
//     String? fullName,
//     String? administrativeUnitShortName,
//   }) {
//     return WardWorkEntity(
//       wardCode: wardCode ?? this.wardCode,
//       name: name ?? this.name,
//       fullName: fullName ?? this.fullName,
//       administrativeUnitShortName: administrativeUnitShortName ?? this.administrativeUnitShortName,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'wardCode': wardCode,
//       'name': name,
//       'fullName': fullName,
//       'administrativeUnitShortName': administrativeUnitShortName,
//     };
//   }

//   factory WardWorkEntity.fromMap(Map<String, dynamic> map) {
//     return WardWorkEntity(
//       wardCode: map['wardCode'] as String,
//       name: map['name'] as String,
//       fullName: map['fullName'] as String,
//       administrativeUnitShortName: map['administrativeUnitShortName'] as String,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory WardWorkEntity.fromJson(String source) => WardWorkEntity.fromMap(json.decode(source) as Map<String, dynamic>);

//   @override
//   String toString() {
//     return 'WardWorkEntity(wardCode: $wardCode, name: $name, fullName: $fullName, administrativeUnitShortName: $administrativeUnitShortName)';
//   }

//   @override
//   bool operator ==(covariant WardWorkEntity other) {
//     if (identical(this, other)) return true;

//     return other.wardCode == wardCode &&
//         other.name == name &&
//         other.fullName == fullName &&
//         other.administrativeUnitShortName == administrativeUnitShortName;
//   }

//   @override
//   int get hashCode {
//     return wardCode.hashCode ^ name.hashCode ^ fullName.hashCode ^ administrativeUnitShortName.hashCode;
//   }
// }
