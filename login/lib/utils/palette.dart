import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

class Palette {
  static Color main = const Color(0xFFFB4C1A);
  static Color iconColor = const Color(0xFFEF3115);
  static Color primaryColor = Colors.blue[500];
  static Color primaryColorDark = Colors.blue[600];
  static Color primaryColorLight = Colors.blue[400];
  static Color primaryColorLightest = Colors.blue[100];
  static Color primaryColorBlack = Colors.blue[800];
  static Color disabledColor = Colors.blue[200];
  static Color okColor = Colors.green[500];
  static Color errorColor = Colors.red[300];
  static SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light,
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    // systemNavigationBarColor: Colors.white,
    // systemNavigationBarIconBrightness: Brightness.dark,
    // systemNavigationBarDividerColor: Colors.white,
  );
}
