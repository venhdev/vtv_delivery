import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/dev.dart';

import '../../features/delivery/presentation/pages/home_page.dart';
import '../../features/delivery/presentation/pages/deliver_profile_page.dart';
import '../../features/delivery/presentation/pages/order_pickup_page.dart';
import '../../dependency_container.dart';

Map<String, Widget Function(BuildContext)> routes = <String, WidgetBuilder>{
  '/': (context) => const HomePage(),
  '/profile': (context) => const DeliverProfilePage(),
  '/scan': (context) => const QrScannerPage(),
  '/qr': (context) => QrViewPage(data: ModalRoute.of(context)!.settings.arguments as String),
  '/pickup': (context) => const OrderPickUpPendingPage(),
  '/dev': (context) => DevPage(sl: sl),
};
