// import 'package:flutter/material.dart';
// import 'package:vendor/features/order/domain/repository/order_vendor_repository.dart';
// import 'package:vtv_common/core.dart';
// import 'package:vtv_common/order.dart';

// import '../../../../core/handler/vendor_handler.dart';
// import '../../../../service_locator.dart';

// const List<OrderStatus> vendorTapPages = [
//   // null,
//   OrderStatus.PENDING, // 0
//   OrderStatus.PROCESSING, // 1
//   OrderStatus.PICKUP_PENDING, // 2
//   OrderStatus.SHIPPING, // 3
//   OrderStatus.DELIVERED, // 4
//   OrderStatus.COMPLETED, // 5
//   OrderStatus.CANCEL, // 6
// ];

// class VendorOrderPurchasePage extends StatefulWidget {
//   const VendorOrderPurchasePage({super.key, this.initialMultiOrders, this.initialIndex = 0});

//   final List<RespData<MultiOrderEntity>>? initialMultiOrders;
//   final int initialIndex;

//   @override
//   State<VendorOrderPurchasePage> createState() => _VendorOrderPurchasePageState();
// }

// class _VendorOrderPurchasePageState extends State<VendorOrderPurchasePage> {
//   FRespData<MultiOrderEntity> _dataCallback(OrderStatus? status) async {
//     // return sl<OrderVendorRepository>().getOrderList();
//     if (status == null) {
//       return sl<OrderVendorRepository>().getOrderList();
//     } else {
//       return sl<OrderVendorRepository>().getOrderListByStatus(status);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return OrderPurchasePage.vendor(
//       appBarTitle: 'Đơn hàng của bạn',
//       actions: [
//         // notification
//         IconButton(
//           icon: const Icon(Icons.notifications),
//           onPressed: () {},
//         ),
//         // chat
//         const IconButton(
//           icon: Icon(Icons.chat),
//           onPressed: null,
//         ),

//         // setting
//         IconButton(
//           icon: const Icon(Icons.settings),
//           onPressed: () {},
//         ),
//       ],
//       dataCallback: _dataCallback,
//       initialMultiOrders: widget.initialMultiOrders,
//       vendorItemBuilder: (order, reloadCallback) => OrderPurchaseItem(
//         order: order,
//         onPressed: () => VendorHandler.navigateToOrderDetailPage(context, order.orderId!),
//         actionBuilder: (status) => buildVendorAction(status, order, reloadCallback, context),
//         // onAccepted: () => VendorHandler.updateOrderStatus(context, order.orderId!, OrderStatus.PROCESSING, reloadCallback),
//         // onWaitingForShipping: () =>
//         //     VendorHandler.updateOrderStatus(context, order.orderId!, OrderStatus.PICKUP_PENDING, reloadCallback),
//       ),
//       pageController: OrderPurchasePageController(tapPages: vendorTapPages, initialIndex: widget.initialIndex),
//     );
//   }

// // ] else ...[
//   Widget buildVendorAction(OrderStatus status, OrderEntity order, VoidCallback reloadCallback, BuildContext context) {
//     switch (status) {
//       case OrderStatus.PENDING:
//         return OrderPurchaseItemAction(
//           label: 'Xác nhận đơn hàng này?',
//           buttonLabel: 'Xác nhận',
//           onPressed: () =>
//               VendorHandler.updateOrderStatus(context, order.orderId!, OrderStatus.PROCESSING, reloadCallback),
//           backgroundColor: Colors.blue.shade100,
//           buttonColor: Colors.blue.shade200,
//         );

//       case OrderStatus.PROCESSING:
//         return OrderPurchaseItemAction(
//           label: 'Đơn hàng đã chuẩn bị xong?',
//           buttonLabel: 'Chờ giao hàng',
//           onPressed: () =>
//               VendorHandler.updateOrderStatus(context, order.orderId!, OrderStatus.PICKUP_PENDING, reloadCallback),
//           backgroundColor: Colors.orange.shade100,
//           buttonColor: Colors.orange.shade400,
//         );
//       // case OrderStatus.PICKUP_PENDING:
//       //   // show qr code
//       //   return OrderPurchaseItemAction(
//       //     label: 'Hiển thị mã QR cho người giao hàng',
//       //     buttonLabel: 'Mở',
//       //     onPressed: () => Navigator.of(context).push(
//       //       MaterialPageRoute(
//       //         builder: (context) {
//       //           return const QRViewPage(data: order.idNotHere);
//       //         },
//       //       ),
//       //     ),
//       //   );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
