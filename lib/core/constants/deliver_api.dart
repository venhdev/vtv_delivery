//! order-shop-controller
// const String kAPIVendorOrderUpdateStatusURL = '/vendor/order/update/:orderId/status/:status';
// const String kAPIVendorOrderListURL = '/vendor/order/list';
// const String kAPIVendorOrderListStatusURL = '/vendor/order/list/status';
// const String kAPIVendorOrderDetailURL = '/vendor/order/detail'; // {orderId}

//! deliver-controller
const String kAPIDeliverInfoURL = '/shipping/deliver/info';

//! transport-controller
const String kAPITransportGetWardURL = '/shipping/transport/get/ward'; // {wardCode}
const String kAPITransportGetByWardWorkURL = '/shipping/transport/get-by-ward-work';
const String kAPITransportUpdateStatusURL = '/shipping/transport/update-status'; // {transportId}