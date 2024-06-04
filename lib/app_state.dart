import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:delivery/core/constants/global_variables.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vtv_common/constant.dart';
import 'package:vtv_common/core.dart';

class AppState extends ChangeNotifier {
  final Connectivity _connectivity;

  AppState(this._connectivity, {this.overlayEntry});

  /// Initializes the app state.
  /// - Checks if the device has an internet connection.
  Future<void> init() async {
    hasConnection = await _connectivity.checkConnectivity().then((connection) {
      return connection[0] != ConnectivityResult.none;
    });

    await _checkServerConnection();
    subscribeConnection();
  }

  //*---------------------Server Connection-----------------------*//
  /// return null when the server is being checked
  bool? _isServerDown;
  bool? get isServerDown => _isServerDown;
  // final OverlayPortalController overlayController = OverlayPortalController();
  Future<void> _checkServerConnection() async {
    _isServerDown = null;
    notifyListeners();

    final dio = Dio(BaseOptions(connectTimeout: VTVConstant.serverCheckConnectTimeout));
    await dio.getUri(uriBuilder(path: '/')).then(
      (_) {},
      onError: (e) {
        if ((e as DioException).response != null) {
          _isServerDown = false;
        } else {
          _isServerDown = true;
        }
        notifyListeners();
      },
    );
  }

  // retry connection to the server
  Future<void> retryConnection() async {
    await _checkServerConnection();
  }

  //*---------------------Connectivity-----------------------
  OverlayEntry? overlayEntry;
  bool hasConnection = true;
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _connectivity.onConnectivityChanged;
  void removeOverlay() {
    try {
      overlayEntry?.remove();
    } catch (e) {
      Logger().e(e);
    }
  }

  void _toggleOverlayBaseOnConnection(bool isConnected) {
    try {
      if (!isConnected) {
        overlayEntry = OverlayEntry(builder: (_) => const NoConnectionOverlay(imagePath: 'assets/images/loading.gif'));
        if (GlobalVariables.rootOverlay.currentState?.mounted == true) {
          GlobalVariables.rootOverlay.currentState?.insert(overlayEntry!);
        } else {
          Logger().i('rootOverlay.currentState?.mounted == false');
        }
      } else {
        overlayEntry?.remove();
        overlayEntry?.dispose();
        overlayEntry = null;
      }
    } catch (e) {
      Logger().e(e);
    }
  }

  /// subscribe to the connectivity stream, the [hasConnection] will be updated
  void subscribeConnection() {
    onConnectivityChanged.listen((List<ConnectivityResult> connection) {
      hasConnection = connection[0] != ConnectivityResult.none;
      _toggleOverlayBaseOnConnection(hasConnection);

      notifyListeners();
    });
  }
}
