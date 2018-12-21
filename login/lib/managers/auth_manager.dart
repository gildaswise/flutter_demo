import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_demo/l10n/translation.dart';
import 'package:flutter_demo/managers/snapshot.dart';
import 'package:flutter_demo/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthError { UNKNOWN, INVALID_CREDENTIALS, EMAIL_IN_USE }

class EmailError {
  static const String INVALID_CREDENTIALS = "Invalid credentials!";
  static const String EMAIL_IN_USE =
      "The email address is already in use by another account.";
}

class AuthManager {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String TAG = "AUTH_MANAGER";

  static AuthManager _instance;

  static AuthManager get instance {
    if (_instance == null) _instance = AuthManager();
    return _instance;
  }

  static String getErrorMessage(Translation translation, AuthError error) {
    switch (error) {
      case AuthError.EMAIL_IN_USE:
        return translation.errorEmailInUse;
      case AuthError.INVALID_CREDENTIALS:
        return translation.errorInvalidCredentials;
      case AuthError.UNKNOWN:
        return translation.errorSignIn;
      default:
        return translation.errorOcurred;
    }
  }

  Future<FirebaseUser> get currentUser async => await _auth.currentUser();

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<Snapshot<GoogleSignInAccount>> getGoogleAccount() async {
    AuthError error;
    GoogleSignInAccount googleAccount = _googleSignIn.currentUser;
    if (googleAccount == null) {
      googleAccount =
          await _googleSignIn.signIn().catchError((exception, stacktrace) {
        Logger.log(TAG, message: "Error occurred: $exception, $stacktrace");
        error = AuthError.UNKNOWN;
        return null;
      });
    }
    return Snapshot<GoogleSignInAccount>(
      data: googleAccount,
      error: error,
    );
  }

  Future<Snapshot<FirebaseUser>> signInWithEmailAndPassword(
      String email, String password) async {
    dynamic error;
    FirebaseUser firebaseUser;

    final exceptionHandler = (exception, stacktrace) {
      Logger.log(TAG, message: "Error occurred: $exception, $stacktrace");
      if (exception is PlatformException) {
        error = Platform.isIOS ? exception.details : exception.message;
      } else {
        error = AuthError.UNKNOWN;
      }
    };

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      error = AuthError.INVALID_CREDENTIALS;
    } else {
      firebaseUser = await _auth.currentUser();
      if (firebaseUser == null) {
        await _auth
            .fetchProvidersForEmail(email: email)
            .catchError(exceptionHandler)
            .then((providers) async {
          if (providers != null && (providers?.contains("password") ?? false)) {
            firebaseUser = await _auth
                .signInWithEmailAndPassword(email: email, password: password)
                .catchError(exceptionHandler);
          } else {
            firebaseUser = await _auth
                .createUserWithEmailAndPassword(
                    email: email, password: password)
                .catchError(exceptionHandler);
          }
        });
      }
    }
    if (error != null)
      Logger.log(TAG,
          message: "Error while managing signInWithEmailAndPassword: $error");
    return Snapshot<FirebaseUser>(
      data: firebaseUser,
      error: error,
    );
  }

  Future<Snapshot<FirebaseUser>> signInWithGoogle(
      GoogleSignInAccount googleAccount) async {
    String error;
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (googleAccount == null) error = "Received GoogleSignInAccount is null";
    if (firebaseUser == null && googleAccount != null) {
      final authentication = await googleAccount.authentication;
      firebaseUser = await _auth
          .signInWithGoogle(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      )
          .catchError((exception, stacktrace) {
        Logger.log(TAG, message: "Error occurred: $exception, $stacktrace");
        error = exception.toString();
      });
    }
    if (error != null)
      Logger.log(TAG, message: "signInWithGoogle returning error: $error");
    return Snapshot<FirebaseUser>(
      data: firebaseUser,
      error: error,
    );
  }
}
