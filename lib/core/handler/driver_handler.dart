// import 'package:flutter/material.dart';
// import 'package:vendor/features/order/domain/repository/order_vendor_repository.dart';
// import 'package:vtv_common/core.dart';
// import 'package:vtv_common/order.dart';

// import '../../service_locator.dart';

// class VendorHandler {
//   //! Order
//   // static void updateOrderStatus(BuildContext context, String orderId, OrderStatus status) {
//   static void updateOrderStatus(
//       BuildContext context, String orderId, OrderStatus status, void Function() reloadCallback) async {
//     String statusText(OrderStatus status) {
//       switch (status) {
//         case OrderStatus.PROCESSING:
//           return 'Xác nhận đơn hàng này?';
//         case OrderStatus.PICKUP_PENDING:
//           return 'Xác nhận đơn hàng này đã sẵn sàng để giao?';
//         default:
//           return 'Không xác định';
//       }
//     }

//     final isConfirm = await showDialogToConfirm(
//       context: context,
//       title: statusText(status),
//       confirmText: 'Xác nhận',
//       dismissText: 'Thoát',
//     );

//     if (!isConfirm) return;

//     sl<OrderVendorRepository>().updateOrderStatus(orderId, status).then((respEither) {
//       respEither.fold((error) => showDialogToAlert(context, title: Text(error.message ?? 'Lỗi khi chấp nhận đơn hàng')),
//           (ok) {
//         reloadCallback();
//       });
//     });
//   }

//   static void navigateToOrderDetailPage(BuildContext context, String orderId) {
//     // fetch order detail
//     sl<OrderVendorRepository>().getOrderDetail(orderId).then((respEither) {
//       respEither.fold(
//         (error) => showDialogToAlert(context, title: Text(error.message ?? 'Lỗi khi lấy thông tin đơn hàng')),
//         (ok) => Navigator.of(context).push(
//           MaterialPageRoute(
//             builder: (context) => OrderDetailPage(
//               orderDetail: ok.data!,
//               onCompleteOrderPressed: (_) async => {},
//               onCancelOrderPressed: (_) async => {},
//               onRePurchasePressed: (_) async => {},
//             ),
//           ),
//         ),
//       );
//     });
//   }
// }
