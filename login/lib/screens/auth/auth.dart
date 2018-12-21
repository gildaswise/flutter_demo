import 'package:firebase_auth/firebase_auth.dart' show FirebaseUser;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/l10n/translation.dart';
import 'package:flutter_demo/managers/auth_manager.dart';
import 'package:flutter_demo/screens/auth/auth_email.dart';
import 'package:flutter_demo/screens/auth/widgets/google_sign_in_btn.dart';
import 'package:flutter_demo/screens/auth/widgets/legal_info.dart';
import 'package:flutter_demo/screens/main.dart';
import 'package:flutter_demo/utils/palette.dart';
import 'package:flutter_demo/widgets/flat_icon_button.dart';
import 'package:flutter_demo/widgets/white_app_bar.dart';
import 'package:google_sign_in/google_sign_in.dart' show GoogleSignInAccount;

class AuthScreen extends StatefulWidget {
  static const String TAG = "AUTH";

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthManager _manager = AuthManager.instance;

  Translation translation;

  bool _loading = false;

  _showSnackBar(String message) {
    if (mounted && message != null && message.isNotEmpty) {
      setState(() {
        this._loading = false;
      });
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(
            message,
          ),
        ),
      );
    }
  }

  _signInWithGoogle() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    GoogleSignInAccount googleAccount;
    final googleAccountSnapshot = await _manager.getGoogleAccount();
    if (googleAccountSnapshot.hasError) {
      _showSnackBar(AuthManager.getErrorMessage(
          translation, googleAccountSnapshot.error));
      return;
    } else if (googleAccountSnapshot.hasData) {
      googleAccount = googleAccountSnapshot.data;
    }

    FirebaseUser firebaseUser;
    final firebaseUserSnapshot = await _manager.signInWithGoogle(googleAccount);
    if (firebaseUserSnapshot.hasError) {
      _showSnackBar(
          AuthManager.getErrorMessage(translation, firebaseUserSnapshot.error));
      return;
    } else if (firebaseUserSnapshot.hasData) {
      firebaseUser = firebaseUserSnapshot.data;
    }

    if (firebaseUser != null) {
      await Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
          settings: RouteSettings(name: HomeScreen.TAG),
          builder: (context) => HomeScreen(user: firebaseUser),
        ),
        (route) => false,
      );
    } else {
      _showSnackBar(translation.errorSignIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (translation == null) translation = Translation.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: WhiteAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FlutterLogo(size: 128.0),
            SizedBox(height: 24.0),
            _loading
                ? CircularProgressIndicator(
                    key: ValueKey("sign-in-progress"),
                  )
                : GoogleSignInButton(
                    key: ValueKey("google-sign-in"),
                    onPressed: _signInWithGoogle,
                  ),
            Offstage(
              offstage: _loading,
              child: FlatIconButton(
                key: ValueKey("email-sign-in"),
                icon: Icon(
                  Icons.alternate_email,
                  size: 20.0,
                  color: Palette.primaryColorDark,
                ),
                label: Text(
                  translation.signInWithEmail,
                  style: textTheme.button.copyWith(
                    color: Palette.primaryColorDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => EmailAuthScreen(),
                      ),
                    ),
              ),
            ),
            Offstage(
              offstage: _loading,
              child: LegalInfoWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
