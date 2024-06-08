import 'package:delivery/features/cash/domain/entities/cash_order_by_date_entity.dart';

import 'package:delivery/features/cash/domain/entities/request/transfer_money_request.dart';

import 'package:delivery/features/cash/domain/entities/response/cash_order_response.dart';
import 'package:vtv_common/core.dart';

import '../../domain/repository/cash_repository.dart';
import '../datasources/cash_data_source.dart';

class CashRepositoryImpl implements CashRepository {
  CashRepositoryImpl(this._cashDataSource);

  final CashDataSource _cashDataSource;

  @override
  FRespData<CashOrderResp> confirmTransfersMoneyByWarehouse(TransferMoneyRequest req) async {
    return await handleDataResponseFromDataSource(
        dataCallback: () => _cashDataSource.confirmTransfersMoneyByWarehouse(req));
  }

  @override
  FRespData<List<CashOrderByDateEntity>> historyByShipper(({bool shipperHold, bool shipping}) shipperType) async {
    return await handleDataResponseFromDataSource(dataCallback: () => _cashDataSource.historyByShipper(shipperType));
  }

  @override
  FRespData<List<CashOrderByDateEntity>> historyByWareHouse(({bool handlePayment, bool warehouseHold}) warehouseType) async {
    return await handleDataResponseFromDataSource(
        dataCallback: () => _cashDataSource.historyByWareHouse(warehouseType));
  }

  @override
  FRespData<CashOrderResp> listByShipper() async {
    return await handleDataResponseFromDataSource(dataCallback: () => _cashDataSource.listByShipper());
  }

  @override
  FRespData<CashOrderResp> listByWareHouse() async {
    return await handleDataResponseFromDataSource(dataCallback: () => _cashDataSource.listByWareHouse());
  }

  @override
  FRespData<CashOrderResp> transfersMoneyWarehouseByShipper(TransferMoneyRequest req) async {
    return await handleDataResponseFromDataSource(
        dataCallback: () => _cashDataSource.transfersMoneyWarehouseByShipper(req));
  }
}
