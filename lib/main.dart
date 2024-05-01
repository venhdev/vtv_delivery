import 'package:driver/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/core.dart';

import 'config/firebase_options.dart';
import 'driver_app.dart';

void main() async {
  // WidgetsBinding widgetsBinding =
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeLocator();
  sl<LocalNotificationUtils>().init();
  sl<FirebaseCloudMessagingManager>().init();

  final authCubit = sl<AuthCubit>()..onStarted();

  // // NOTE: dev
  // final domain = sl<SharedPreferencesHelper>().I.getString('devDomain');
  // if (domain != null) {
  //   // devDOMAIN = domain;
  //   devDOMAIN = '192.168.1.12';

  // }

  devDOMAIN = '192.168.1.12';

  runApp(MultiProvider(
    providers: [
      BlocProvider(create: (context) => authCubit),
    ],
    child: const DriverApp(),
  ));
}
