import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/dev.dart';

import '../../app_scaffold.dart';
import '../../features/delivery/presentation/pages/deliver_profile_page.dart';
import '../../features/delivery/presentation/pages/delivery_scanner_page.dart';
import '../../features/delivery/presentation/pages/order_pickup_page.dart';
import '../../dependency_container.dart';

Map<String, Widget Function(BuildContext)> routes = <String, WidgetBuilder>{
  '/': (context) => const AppScaffold(),
  '/profile': (context) => const DeliverProfilePage(),
  DeliveryScannerPage.routeName: (context) => const DeliveryScannerPage(),
  '/scan': (context) => QrScanner(
        options: (context, controller) {
          controller.start();
          controller.barcodes.listen((data) {
            controller.stop();
            if (!context.mounted) return;
            Navigator.pop(context, data.barcodes.first.rawValue!);
          });
        },
      ),
  '/qr': (context) => QrViewPage(data: ModalRoute.of(context)!.settings.arguments as String),
  '/pickup': (context) => const PickUpPendingOrderPage(),
  '/dev': (context) => DevPage(sl: sl),
};
