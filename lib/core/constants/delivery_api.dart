//# deliver-controller
const String kAPIDeliverInfoURL = '/shipping/deliver/info';

//# transport-controller
const String kAPITransportGetWardURL = '/shipping/transport/get/ward'; // {wardCode}
const String kAPITransportGetByWardWorkURL = '/shipping/transport/get-by-ward-work';
const String kAPITransportUpdateStatusURL = '/shipping/transport/update-status'; // {transportId}
const String kAPITransportGetURL = '/shipping/transport/get'; // {transportId}
const String kAPITransportSuccessReturnURL = '/shipping/transport/success-return/{transportId}';
const String kAPITransportCancelReturnURL = '/shipping/transport/cancel-return/{transportId}';
// for warehouse forced return some order that cannot be delivered
const String kAPITransportReturnWarehouseURL = '/shipping/transport/return/warehouse/{transportId}';
const String kAPITransportUpdateStatusReturnOrderURL = '/shipping/transport/return/update-status/{transportId}';

//# cash-order-controller
const String kAPICashOrderTransfersMoneyWarehouseURL = '/shipping/cash-order/updates/transfers-money-warehouse';
const String kAPICashOrderConfirmMoneyWarehouseURL = '/shipping/cash-order/updates/confirm-money-warehouse';
const String kAPICashOrderListByWareHouseURL = '/shipping/cash-order/list-by-wave-house';
const String kAPICashOrderHistoryByWarehouseURL = '/shipping/cash-order/history-by-warehouse';
const String kAPICashOrderHistoryByShipperURL = '/shipping/cash-order/history-by-shipper';
const String kAPICashOrderAllByShipperURL = '/shipping/cash-order/all-by-shipper';
const String kAPICashOrderDetailURL = '/shipping/cash-order/detail';
