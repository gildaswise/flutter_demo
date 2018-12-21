import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/managers/auth_manager.dart';
import 'package:flutter_demo/screens/auth/auth.dart';
import 'package:flutter_demo/screens/main.dart';
import 'package:flutter_demo/utils/logger.dart';
import 'package:flutter_demo/utils/palette.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String TAG = "SPLASH";
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(debugLabel: "scaffold-splash");
  final AuthManager _manager = AuthManager.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  proceed(FirebaseUser user) async =>
      await Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          settings: RouteSettings(
              name: (user != null) ? HomeScreen.TAG : AuthScreen.TAG),
          builder: (context) =>
              (user != null) ? HomeScreen(user: user) : AuthScreen(),
        ),
      );

  init() async {
    await Future.delayed(Duration(seconds: 2));
    final user = await _manager.currentUser.catchError((exception, stacktrace) {
      Logger.log(TAG, message: "Couldn't get user: $exception");
    });
    return proceed(user);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(Palette.overlayStyle);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Center(
        child: FlutterLogo(
          key: ValueKey("image-logo"),
          size: 128.0,
        ),
      ),
    );
  }
}
