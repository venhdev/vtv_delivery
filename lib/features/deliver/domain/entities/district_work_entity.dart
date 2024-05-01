import 'dart:convert';

class DistrictWorkEntity {
  final String districtCode;
  final String name;
  final String fullName;
  final String administrativeUnitShortName;
  final String provinceCode;
  final String provinceName;

  DistrictWorkEntity({
    required this.districtCode,
    required this.name,
    required this.fullName,
    required this.administrativeUnitShortName,
    required this.provinceCode,
    required this.provinceName,
  });

  DistrictWorkEntity copyWith({
    String? districtCode,
    String? name,
    String? fullName,
    String? administrativeUnitShortName,
    String? provinceCode,
    String? provinceName,
  }) {
    return DistrictWorkEntity(
      districtCode: districtCode ?? this.districtCode,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      administrativeUnitShortName: administrativeUnitShortName ?? this.administrativeUnitShortName,
      provinceCode: provinceCode ?? this.provinceCode,
      provinceName: provinceName ?? this.provinceName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'districtCode': districtCode,
      'name': name,
      'fullName': fullName,
      'administrativeUnitShortName': administrativeUnitShortName,
      'provinceCode': provinceCode,
      'provinceName': provinceName,
    };
  }

  factory DistrictWorkEntity.fromMap(Map<String, dynamic> map) {
    return DistrictWorkEntity(
      districtCode: map['districtCode'] as String,
      name: map['name'] as String,
      fullName: map['fullName'] as String,
      administrativeUnitShortName: map['administrativeUnitShortName'] as String,
      provinceCode: map['provinceCode'] as String,
      provinceName: map['provinceName'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DistrictWorkEntity.fromJson(String source) =>
      DistrictWorkEntity.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DistrictWorkEntity(districtCode: $districtCode, name: $name, fullName: $fullName, administrativeUnitShortName: $administrativeUnitShortName, provinceCode: $provinceCode, provinceName: $provinceName)';
  }

  @override
  bool operator ==(covariant DistrictWorkEntity other) {
    if (identical(this, other)) return true;

    return other.districtCode == districtCode &&
        other.name == name &&
        other.fullName == fullName &&
        other.administrativeUnitShortName == administrativeUnitShortName &&
        other.provinceCode == provinceCode &&
        other.provinceName == provinceName;
  }

  @override
  int get hashCode {
    return districtCode.hashCode ^
        name.hashCode ^
        fullName.hashCode ^
        administrativeUnitShortName.hashCode ^
        provinceCode.hashCode ^
        provinceName.hashCode;
  }
}
