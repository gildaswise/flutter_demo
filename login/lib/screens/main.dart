import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/l10n/translation.dart';
import 'package:flutter_demo/managers/auth_manager.dart';
import 'package:flutter_demo/screens/auth/auth.dart';
import 'package:flutter_demo/widgets/flat_icon_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatelessWidget {
  static const String TAG = "HOME_SCREEN";
  final FirebaseUser user;

  const HomeScreen({Key key, @required this.user})
      : assert(user != null),
        super(key: key);

  _onSignOut(BuildContext context) async {
    await AuthManager.instance.signOut();
    await Navigator.of(context).pushAndRemoveUntil(
        CupertinoPageRoute(
            settings: RouteSettings(name: AuthScreen.TAG),
            builder: (context) => AuthScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translation = Translation.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Offstage(
              offstage: user.photoUrl == null,
              child: CircleAvatar(
                  backgroundImage: NetworkImage(user?.photoUrl ?? "")),
            ),
            SizedBox(height: 8.0),
            Text(user?.displayName ?? translation.emptyName,
                style: theme.textTheme.title),
            Text(user?.email ?? translation.exampleEmail),
            SizedBox(height: 16.0),
            FlatIconButton(
              icon: Icon(Icons.exit_to_app),
              label: Text(translation.signOut),
              onPressed: () => _onSignOut(context),
            )
          ],
        ),
      ),
    );
  }
}
