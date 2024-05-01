// // ignore_for_file: prefer_const_constructors

// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vtv_common/auth.dart';
// import 'package:vtv_common/core.dart';
// import 'package:vtv_common/dev.dart';

// import '../../../features/order/presentation/pages/vendor_order_purchase_page.dart';
// import '../../../service_locator.dart';

// class AppDrawer extends StatefulWidget {
//   const AppDrawer({
//     super.key,
//     required this.onItemTapped,
//     required this.selectedIndex,
//   });

//   final int selectedIndex;
//   final void Function(int index) onItemTapped;

//   @override
//   State<AppDrawer> createState() => _AppDrawerState();
// }

// class _AppDrawerState extends State<AppDrawer> {
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: ListView(
//         padding: EdgeInsets.zero,
//         children: [
//           BlocConsumer<AuthCubit, AuthState>(
//             listener: (context, state) {
//               // if (state.message != null) {
//               //   ScaffoldMessenger.of(context)
//               //     ..hideCurrentSnackBar
//               //     ..showSnackBar(
//               //       SnackBar(
//               //         content: Text(state.message!),
//               //         duration: const Duration(seconds: 2),
//               //       ),
//               //     );
//               // }
//             },
//             builder: (context, state) {
//               if (state.status == AuthStatus.authenticated) {
//                 final auth = state.auth!;
//                 return UserAccountsDrawerHeader(
//                   accountName: Text(
//                     auth.userInfo.fullName ?? auth.userInfo.username ?? 'User',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   accountEmail: Text(
//                     auth.userInfo.email ?? 'Email',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   currentAccountPicture: FlutterLogo(),
//                   otherAccountsPictures: [
//                     // logout icon
//                     IconButton(
//                       icon: const Icon(Icons.logout, color: Colors.red),
//                       onPressed: () async {
//                         await context.read<AuthCubit>().logout(state.auth!.refreshToken);
//                         if (context.mounted) {
//                           Navigator.pop(context);
//                         }
//                       },
//                     ),
//                   ],
//                 );
//               } else if (state.status == AuthStatus.unauthenticated) {
//                 return _authenticatedDrawerHeader(context);
//               }
//               return DrawerHeader(
//                 child: Center(
//                   child: Column(
//                     children: [
//                       const Text(
//                         'Đang tải...',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           log(state.toString());
//                         },
//                         child: const Text('Button'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           log('current domain: $devDOMAIN');
//                         },
//                         child: const Text('current domain'),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           ListTile(
//             title: const Text('Tổng quan cửa hàng'),
//             selected: widget.selectedIndex == 0,
//             onTap: () {
//               widget.onItemTapped(0);
//               Navigator.pop(context);
//             },
//           ),
//           BlocBuilder<AuthCubit, AuthState>(
//             builder: (context, state) {
//               if (state.status != AuthStatus.authenticated) return const SizedBox.shrink();
//               return ListTile(
//                 title: const Text('Đơn hàng của bạn'),
//                 selected: widget.selectedIndex == 1,
//                 onTap: () {
//                   // widget.onItemTapped(1);
//                   // Navigator.pop(context);
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) {
//                         return VendorOrderPurchasePage();
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//           // divider
//           const Divider(),
//           ListTile(
//             title: const Text('Dev Page'),
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) {
//                     return DevPage(sl: sl);
//                   },
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   DrawerHeader _authenticatedDrawerHeader(BuildContext context) {
//     return DrawerHeader(
//       child: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//             // Navigator.of(context).push(
//             //   MaterialPageRoute(
//             //     builder: (context) {
//             //       return VendorLoginPage();
//             //     },
//             //   ),
//             // );
//           },
//           child: const Text('Đăng nhập'),
//         ),
//       ),
//     );
//   }
// }

// class AppDrawerItem extends StatelessWidget {
//   const AppDrawerItem({super.key, required this.title, required this.selected, required this.onPressed});

//   final String title;
//   final bool selected;
//   final void Function() onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: const Text('Dev Page'),
//       selected: selected,
//       onTap: onPressed,
//     );
//   }
// }
