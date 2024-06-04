import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vtv_common/auth.dart';
import 'package:vtv_common/config.dart';
import 'package:vtv_common/core.dart';
import 'package:vtv_common/guest.dart';

import 'config/dio/delivery_auth_interceptor.dart';
import 'core/handler/delivery_redirect.dart';
import 'features/delivery/data/data_sources/deliver_data_source.dart';
import 'features/delivery/data/repository/deliver_repository_impl.dart';
import 'features/delivery/domain/repository/deliver_repository.dart';

// Service locator
GetIt sl = GetIt.instance;

Future<void> initializeLocator() async {
  //! External
  // final connectivity = Connectivity();
  final sharedPreferences = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage();

  final fMessaging = FirebaseMessaging.instance;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final dio = Dio(dioOptions);
  dio.interceptors.addAll(
    [
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
      ),
      DeliveryAuthInterceptor(),
      ErrorInterceptor(),
    ],
  );

  sl.registerSingleton<http.Client>(http.Client());
  sl.registerSingleton<Dio>(dio);
  // sl.registerSingleton<Connectivity>(connectivity);

  //! Core - Helpers - Managers
  sl.registerSingleton<SharedPreferencesHelper>(SharedPreferencesHelper(sharedPreferences));
  sl.registerSingleton<SecureStorageHelper>(SecureStorageHelper(secureStorage));

  sl.registerSingleton<LocalNotificationHelper>(LocalNotificationHelper(flutterLocalNotificationsPlugin));
  sl.registerSingleton<FirebaseCloudMessagingManager>(FirebaseCloudMessagingManager(fMessaging));

  //! Data source
  sl.registerSingleton<GuestDataSource>(GuestDataSourceImpl(sl()));
  sl.registerSingleton<AuthDataSource>(AuthDataSourceImpl(sl(), sl(), sl(), sl()));

  sl.registerSingleton<DeliverDataSource>(DeliverDataSourceImpl(sl()));

  //! Repository
  sl.registerSingleton<GuestRepository>(GuestRepositoryImpl(sl()));
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl(sl(), sl()));

  sl.registerSingleton<DeliverRepository>(DeliverRepositoryImpl(sl()));

  //! UseCase
  sl.registerLazySingleton<LoginWithUsernameAndPasswordUC>(() => LoginWithUsernameAndPasswordUC(sl()));
  sl.registerLazySingleton<LogoutUC>(() => LogoutUC(sl()));
  sl.registerLazySingleton<CheckTokenUC>(() => CheckTokenUC(sl()));

  //! Bloc
  sl.registerFactory(() => AuthCubit(
        sl(),
        sl(),
        sl(),
        sl(),
        DeliverAuthRedirect(redirect: {}),
      ));
}

// <https://pub.dev/packages/get_it>
