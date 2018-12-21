import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/l10n/translation.dart';
import 'package:flutter_demo/managers/auth_manager.dart';
import 'package:flutter_demo/screens/auth/blocs/auth_bloc.dart';
import 'package:flutter_demo/screens/auth/widgets/legal_info.dart';
import 'package:flutter_demo/screens/bloc_provider.dart';
import 'package:flutter_demo/screens/main.dart';
import 'package:flutter_demo/utils/logger.dart';
import 'package:flutter_demo/utils/palette.dart';
import 'package:flutter_demo/widgets/white_app_bar.dart';

class ResetPasswordWidget extends StatelessWidget {
  final String email;
  final GlobalKey<ScaffoldState> scaffoldKey;

  ResetPasswordWidget({Key key, this.email, this.scaffoldKey})
      : super(key: key);

  final _auth = FirebaseAuth.instance;

  _onTap(Translation translation) async {
    _auth
        .sendPasswordResetEmail(email: this.email)
        .catchError((exception, stacktrace) {
      Logger.log(EmailAuthScreen.TAG,
          message: "Couldn't send password reset: $exception");
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(translation.errorPasswordReset),
      ));
    }).then((value) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(translation.sentPasswordReset),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final translation = Translation.of(context);
    final textTheme = Theme.of(context).textTheme;
    final captionStyle = textTheme.caption.copyWith(
      fontSize: 13.0,
    );
    final linkStyle = captionStyle.copyWith(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      color: Palette.primaryColorBlack,
    );
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: translation.passwordReset, style: captionStyle),
          TextSpan(
            text: translation.here.toLowerCase(),
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () => _onTap(translation),
          )
        ],
      ),
    );
  }
}

class EmailAuthScreen extends StatefulWidget {
  static const String TAG = "EMAIL_AUTH";

  @override
  _EmailAuthScreenState createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthManager _manager = AuthManager.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final PageController _pageController = PageController(keepPage: true);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;

  AnimationController _animationController;
  Animation<Offset> _slideTransition;
  Translation translation;
  String _buttonText;
  AuthBloc _bloc;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      animationBehavior: AnimationBehavior.normal,
    );

    _slideTransition = Tween<Offset>(
      begin: const Offset(5.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.ease,
    ));
  }

  _showLoading(bool value) {
    if (mounted) {
      setState(() {
        _loading = value;
      });
    }
  }

  _showError(String error) {
    _showLoading(false);
    if (mounted) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(error ?? translation.errorOcurred),
      ));
    }
  }

  String _verifyProviders(List<String> providers) {
    if (providers == null || providers.isEmpty) return translation.errorEmpty;
    for (String provider in providers) {
      if (provider.contains("google")) return translation.errorGoogleProvider;
    }
    return null;
  }

  _verifyEmail() async {
    final String email =
        await _bloc.email.first.catchError((exception) => null);
    if (email != null && email.isNotEmpty) {
      _showLoading(true);
      await _auth
          .fetchProvidersForEmail(email: email)
          .catchError((exception, stacktrace) {
        Logger.log(EmailAuthScreen.TAG,
            message: "Error ocurred on fetching providers: $exception");
        _showError(translation.errorVerifyEmail);
      }).then((providers) async {
        final message = _verifyProviders(providers);
        if (message != null && message != translation.errorEmpty) {
          _showError(message);
        } else {
          if (mounted) {
            _showLoading(false);
            setState(() => _buttonText = message == translation.errorEmpty
                ? translation.signUp
                : translation.signIn);
            await _pageController.animateToPage(
              1,
              curve: Curves.easeOut,
              duration: Duration(milliseconds: 400),
            );
          }
        }
      });
    } else {
      _showLoading(false);
      _bloc?.updateEmailError(translation.errorEmpty);
    }
  }

  _proceed(FirebaseUser user) => Navigator.of(context).pushAndRemoveUntil(
      CupertinoPageRoute(
        settings: RouteSettings(name: HomeScreen.TAG),
        builder: (context) => HomeScreen(user: user),
      ),
      (route) => false);

  _signIn() async {
    if (await _bloc.submitValid.first) {
      _showLoading(true);
      final snapshot = await _manager.signInWithEmailAndPassword(
        await _bloc.email.first,
        await _bloc.password.first,
      );

      if (snapshot.success) {
        _proceed(snapshot.data);
      } else {
        if (snapshot.error is String)
          _showError(snapshot.error);
        else if (snapshot.error is AuthError)
          _showError(AuthManager.getErrorMessage(translation, snapshot.error));
      }
    }
  }

  _handleSignIn() async {
    switch (_pageController.page.ceil()) {
      case 0:
        await _verifyEmail();
        break;
      case 1:
        await _signIn();
        break;
    }
  }

  _handleAnimation(int position) async {
    if (mounted && _buttonText != translation.signUp) {
      if (position == 0) {
        await _animationController.reverse();
      } else {
        await _animationController.forward();
      }
    }
  }

  Widget firstPage() {
    return StreamBuilder(
      stream: _bloc.email,
      builder: (context, snapshot) => Center(
            child: _loading
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      key: ValueKey("text-field-email"),
                      controller: _emailController,
                      onChanged: _bloc.updateEmail,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: translation.email,
                        hintText: translation.exampleEmail,
                        errorText: snapshot.error,
                        contentPadding: const EdgeInsets.all(12.0),
                      ),
                    ),
                  ),
          ),
    );
  }

  Widget secondPage() {
    return StreamBuilder(
      stream: _bloc.password,
      builder: (context, snapshot) => Center(
            child: _loading
                ? CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      key: ValueKey("text-field-password"),
                      obscureText: true,
                      controller: _passwordController,
                      onChanged: _bloc.updatePassword,
                      maxLength: _buttonText == translation.signUp ? 16 : null,
                      inputFormatters: [LengthLimitingTextInputFormatter(16)],
                      decoration: InputDecoration(
                        errorText: snapshot.error,
                        labelText: translation.password,
                        helperText: _buttonText == translation.signUp
                            ? translation.passwordHelper
                            : null,
                        contentPadding: const EdgeInsets.all(12.0),
                        prefixIcon: IconButton(
                          icon: Icon(Icons.arrow_back_ios),
                          tooltip: translation.previous,
                          onPressed: () async {
                            if (mounted) {
                              setState(() => _buttonText = translation.next);
                              await _pageController.animateToPage(
                                0,
                                curve: Curves.easeOut,
                                duration: Duration(milliseconds: 400),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (translation == null) translation = Translation.of(context);
    if (_buttonText == null) _buttonText = translation.next;
    if (_bloc == null) _bloc = AuthBloc(AuthBlocValidator(translation));
    return BlocProvider<AuthBloc>(
      bloc: _bloc,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: WhiteAppBar(iconTheme: Theme.of(context).iconTheme),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0.0
            ? FloatingActionButton.extended(
                key: ValueKey("fab-email"),
                tooltip: translation.next,
                icon: Icon(Icons.chevron_right),
                label: Text(_buttonText),
                backgroundColor: _loading ? Colors.grey : Palette.primaryColor,
                onPressed: _loading ? null : _handleSignIn,
              )
            : null,
        body: Center(
          child: Flex(
            direction: Axis.vertical,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(flex: 1, child: FlutterLogo(size: 128.0)),
              Flexible(child: LegalInfoWidget()),
              Flexible(
                flex: 0,
                child: Offstage(
                  offstage: _buttonText == translation.signUp,
                  child: SlideTransition(
                    position: _slideTransition,
                    child: ResetPasswordWidget(
                      email: _emailController.text,
                      scaffoldKey: _scaffoldKey,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: PageView(
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  pageSnapping: true,
                  controller: _pageController,
                  onPageChanged: _handleAnimation,
                  children: <Widget>[
                    firstPage(),
                    secondPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
