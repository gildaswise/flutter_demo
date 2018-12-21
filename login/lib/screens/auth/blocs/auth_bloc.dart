import 'dart:async';

import 'package:flutter_demo/l10n/translation.dart';
import 'package:flutter_demo/screens/bloc_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/l10n/translation.dart';
import 'package:rxdart/rxdart.dart';

class AuthBlocValidator {
  final Translation translation;

  AuthBlocValidator(this.translation) : assert(translation != null);

  StreamTransformer<String, String> get validateEmail =>
      StreamTransformer<String, String>.fromHandlers(
        handleData: (email, sink) {
          String validationRule =
              r"\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b";
          if (RegExp(validationRule).hasMatch(email)) {
            sink.add(email);
          } else if (email.isEmpty) {
            sink.addError(translation.errorEmpty);
          } else {
            sink.addError(translation.errorEmailInvalid);
          }
        },
      );

  StreamTransformer<String, String> get validatePassword =>
      StreamTransformer<String, String>.fromHandlers(
        handleData: (password, sink) {
          if (password.length >= 8) {
            sink.add(password);
          } else if (password.isEmpty) {
            sink.addError(translation.errorEmpty);
          } else {
            sink.addError(translation.errorPasswordInvalid);
          }
        },
      );
}

class AuthBloc extends BlocBase {
  static const String TAG = "AUTH_BLOC";

  final AuthBlocValidator validator;

  AuthBloc(this.validator) : assert(validator != null);

  final _emailSubject = BehaviorSubject<String>(seedValue: null);
  final _passwordSubject = BehaviorSubject<String>(seedValue: null);

  Stream<String> get email =>
      _emailSubject.stream.transform(validator.validateEmail);

  Stream<String> get password =>
      _passwordSubject.stream.transform(validator.validatePassword);

  Stream<bool> get submitValid => Observable.combineLatest2(
      email, password, (e, p) => e != null && p != null);

  Function(String) get updateEmail => _emailSubject.sink.add;
  updateEmailError(String error) => _emailSubject.sink.addError(error);
  Function(String) get updatePassword => _passwordSubject.sink.add;
  updatePasswordError(String error) => _passwordSubject.sink.addError(error);

  @override
  dispose() {
    _emailSubject.close();
    _passwordSubject.close();
  }
}
