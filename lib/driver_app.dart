import 'package:flutter/material.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/dev.dart';

import 'features/deliver/presentation/pages/deliver_page.dart';
import 'features/deliver/presentation/pages/deliver_profile_page.dart';
import 'features/deliver/presentation/pages/order_pickup_page.dart';
import 'service_locator.dart';

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VTV Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DeliverPage(),
        '/profile': (context) => const DeliverProfilePage(),
        '/scan': (context) => const QrScannerPage(),
        '/pickup': (context) => const OrderPickUpPage(),
        '/dev': (context) => DevPage(sl: sl),
      },
    );
  }
}
