import 'package:flutter/widgets.dart';

/// Global Variables
class GlobalVariables {
  /// This global key is used in material app for navigation through firebase cloud messaging
  static final GlobalKey<NavigatorState> navigatorState = GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
  static final GlobalKey<OverlayState> rootOverlay = GlobalKey<OverlayState>(debugLabel: 'rootOverlay');
}
