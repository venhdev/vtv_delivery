//# deliver-controller
const String kAPIDeliverInfoURL = '/shipping/deliver/info';

//# transport-controller
const String kAPITransportGetWardURL = '/shipping/transport/get/ward'; // {wardCode}
const String kAPITransportGetByWardWorkURL = '/shipping/transport/get-by-ward-work';
const String kAPITransportUpdateStatusURL = '/shipping/transport/update-status'; // {transportId}
const String kAPITransportGetURL = '/shipping/transport/get'; // {transportId}
//# cash-order-controller
// POST
// /api/shipping/cash-order/updates/transfers-money-warehouse
const String kAPICashOrderTransfersMoneyWarehouseURL = '/shipping/cash-order/updates/transfers-money-warehouse';


// POST
// /api/shipping/cash-order/updates/confirm-money-warehouse
const String kAPICashOrderConfirmMoneyWarehouseURL = '/shipping/cash-order/updates/confirm-money-warehouse';


// GET
// /api/shipping/cash-order/list-by-wave-house
const String kAPICashOrderListByWareHouseURL = '/shipping/cash-order/list-by-wave-house';


// GET
// /api/shipping/cash-order/history-by-warehouse
const String kAPICashOrderHistoryByWarehouseURL = '/shipping/cash-order/history-by-warehouse';


// GET
// /api/shipping/cash-order/history-by-shipper
const String kAPICashOrderHistoryByShipperURL = '/shipping/cash-order/history-by-shipper';


// GET
// /api/shipping/cash-order/all-by-shipper
const String kAPICashOrderAllByShipperURL = '/shipping/cash-order/all-by-shipper';

// GET
// /api/shipping/cash-order/detail/{cashOrderId}
const String kAPICashOrderDetailURL = '/shipping/cash-order/detail';