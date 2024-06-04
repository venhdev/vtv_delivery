import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/dev.dart';

import 'app_state.dart';
import 'config/routes/routes.dart';
import 'core/constants/global_variables.dart';
import 'dependency_container.dart';

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'VTV Delivery',
        navigatorKey: GlobalVariables.navigatorState,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: routes,
        builder: (context, child) => AppBuild(child: child!));
  }
}

class AppBuild extends StatelessWidget {
  const AppBuild({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (child is DevPage) return child;

        if (state.isServerDown == null) {
          return Scaffold(
            body: MessageScreen(
              message: 'Đang kiểm tra kết nối đến máy chủ...',
              icon: Image.asset('assets/images/loading.gif', height: 100, width: 100),
            ),
          );
        } else if (state.isServerDown == true) {
          return const ServerDown();
        } else {
          return Overlay(
            key: GlobalVariables.rootOverlay,
            initialEntries: [
              OverlayEntry(
                builder: (context) => child,
              ),
            ],
          );
        }
      },
    );
  }
}

class ServerDown extends StatefulWidget {
  const ServerDown({
    super.key,
  });

  @override
  State<ServerDown> createState() => _ServerDownState();
}

class _ServerDownState extends State<ServerDown> {
  bool isDevPage = false;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (isDevPage) {
        return Overlay(
          initialEntries: [
            OverlayEntry(builder: (context) => DevPage(sl: sl, onBackPressed: () => setState(() => isDevPage = false)))
          ],
        );
      }

      return Scaffold(
          body: MessageScreen(
        message: 'Không thể kết nối đến máy chủ...',
        icon: const Icon(Icons.wifi_off),
        onPressed: () => Provider.of<AppState>(context, listen: false).retryConnection(),
        onIconLongPressed: () => setState(() => isDevPage = true),
      ));
    });
  }
}
