import 'package:json/json.dart';

@JsonCodable()
class TransferMoneyRequest {
  final List<String> cashOrderIds;
  final String waveHouseUsername;

  const TransferMoneyRequest({
    required this.cashOrderIds,
    required this.waveHouseUsername,
  });

  @override
  String toString() => 'TransferMoneyRequest(cashOrderIds: $cashOrderIds, waveHouseUsername: $waveHouseUsername)';
}
