// // ignore_for_file: prefer_const_constructors

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vtv_common/auth.dart';
// import 'package:vtv_common/core.dart';
// import 'package:vtv_common/order.dart';

// import '../../../features/order/domain/repository/order_vendor_repository.dart';
// import '../../../features/order/presentation/pages/vendor_order_purchase_page.dart';
// import '../../../features/shop/presentation/components/shop_info_detail_view.dart';
// import '../../../service_locator.dart';
// import 'vendor_login_page.dart';

// Future<List<RespData<MultiOrderEntity>>> _futureDataOrders() async {
//   return Future.wait(
//     List.generate(vendorTapPages.length, (index) async {
//       return sl<OrderVendorRepository>().getOrderListByStatus(vendorTapPages[index]);
//     }),
//   );
// }

// class VendorPage extends StatelessWidget {
//   const VendorPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AuthCubit, AuthState>(
//       listener: (context, state) {
//         if (state.message != null) {
//           ScaffoldMessenger.of(context)
//             ..hideCurrentSnackBar()
//             ..showSnackBar(
//               SnackBar(
//                 content: Text(state.message!),
//                 duration: const Duration(seconds: 2),
//               ),
//             );
//         }
//       },
//       builder: (context, state) {
//         if (state.status == AuthStatus.unauthenticated) {
//           return const VendorLoginPage(showTitle: false);
//         }
//         return _buildBody(context);
//       },
//     );
//   }

//   Widget _buildBody(BuildContext context) {
//     return Column(
//       children: const [
//         ShopInfoDetailView(),
//         // vendor's order history
//         OrderPurchaseSummary(),
//       ],
//     );
//   }
// }

// class OrderPurchaseSummary extends StatefulWidget {
//   const OrderPurchaseSummary({
//     super.key,
//   });

//   @override
//   State<OrderPurchaseSummary> createState() => _OrderPurchaseSummaryState();
// }

// class _OrderPurchaseSummaryState extends State<OrderPurchaseSummary> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       future: _futureDataOrders(),
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           return _summaryInfo(context, snapshot.data!);
//           // return SizedBox();
//         } else {
//           return const Center(
//               child: Text(
//             'Đang tải...',
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.black54),
//           ));
//         }
//       },
//     );
//   }

//   Wrapper _summaryInfo(BuildContext context, List<RespData<MultiOrderEntity>> dataList) {
//     void navigateToPage(int index) {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) {
//             return VendorOrderPurchasePage(initialMultiOrders: dataList, initialIndex: index);
//           },
//         ),
//       );
//     }

//     int getIndex(OrderStatus status) {
//       return vendorTapPages.indexWhere((element) => element == status);
//     }

//     return Wrapper(
//       margin: EdgeInsets.only(top: 16),
//       label: WrapperLabel(labelText: 'Đơn hàng của bạn', icon: Icons.shopping_cart_outlined),
//       suffixLabel: Row(
//         children: [
//           // refresh icon button
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: () => setState(() {}),
//           ),

//           TextButton(
//               onPressed: () {
//                 navigateToPage(0);
//                 // Navigator.of(context).push(
//                 //   MaterialPageRoute(
//                 //     builder: (context) {
//                 //       return VendorOrderPurchasePage(initialMultiOrders: dataList);
//                 //     },
//                 //   ),
//                 // );
//               },
//               child: const Text('Xem tất cả')),
//         ],
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Padding(
//           padding: const EdgeInsets.only(top: 8.0),
//           child: Row(
//             children: [
//               dataList[getIndex(OrderStatus.PENDING)].fold(
//                 (error) => const SizedBox.shrink(),
//                 (ok) => OrderHistoryItem(
//                   ok.data!.orders.length,
//                   OrderStatus.PENDING,
//                   onPressed: () => navigateToPage(getIndex(OrderStatus.PENDING)),
//                 ),
//               ),
//               dataList[getIndex(OrderStatus.PROCESSING)].fold(
//                 (error) => const SizedBox.shrink(),
//                 (ok) => OrderHistoryItem(
//                   ok.data!.orders.length,
//                   OrderStatus.PROCESSING,
//                   onPressed: () => navigateToPage(getIndex(OrderStatus.PROCESSING)),
//                 ),
//               ),
//               dataList[getIndex(OrderStatus.PICKUP_PENDING)].fold(
//                 (error) => const SizedBox.shrink(),
//                 (ok) => OrderHistoryItem(
//                   ok.data!.orders.length,
//                   OrderStatus.PICKUP_PENDING,
//                   onPressed: () => navigateToPage(getIndex(OrderStatus.PICKUP_PENDING)),
//                 ),
//               ),
//               dataList[getIndex(OrderStatus.SHIPPING)].fold(
//                 (error) => const SizedBox.shrink(),
//                 (ok) => OrderHistoryItem(
//                   ok.data!.orders.length,
//                   OrderStatus.SHIPPING,
//                   onPressed: () => navigateToPage(getIndex(OrderStatus.SHIPPING)),
//                 ),
//               ),
//               dataList[getIndex(OrderStatus.CANCEL)].fold(
//                 (error) => const SizedBox.shrink(),
//                 (ok) => OrderHistoryItem(
//                   ok.data!.orders.length,
//                   OrderStatus.CANCEL,
//                   onPressed: () => navigateToPage(getIndex(OrderStatus.CANCEL)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OrderHistoryItem extends StatelessWidget {
//   const OrderHistoryItem(
//     this.count,
//     this.status, {
//     super.key,
//     this.onPressed,
//   });

//   final int count;
//   final OrderStatus status;
//   final VoidCallback? onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(8),
//         onTap: onPressed,
//         child: Ink(
//           height: 80,
//           width: 100,
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primaryContainer,
//             borderRadius: BorderRadius.circular(8),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black12,
//                 blurRadius: 4,
//                 offset: Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // count
//               Text(count.toString(), style: const TextStyle(fontSize: 18)),

//               // order status name
//               Text(StringHelper.getOrderStatusName(status),
//                   style: const TextStyle(
//                     fontSize: 12,
//                   ))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
