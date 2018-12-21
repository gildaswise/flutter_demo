import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/l10n/translation.dart';
import 'package:flutter_demo/utils/logger.dart';
import 'package:flutter_demo/utils/palette.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalInfoWidget extends StatelessWidget {
  static const String TAG = "LEGAL_INFO";

  void _launch(String link) async {
    Logger.log(TAG, message: "Verifying link $link");
    final can = await canLaunch(link).catchError((error, stacktrace) {
      Logger.log(TAG, message: "Couldn't launch link: $error");
    });
    if (can) {
      Logger.log(TAG, message: "Launching link $link");
      await launch(link).catchError((error, stacktrace) {
        Logger.log(TAG, message: "Couldn't launch link: $error");
      });
    }
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
      color: Palette.primaryColor,
    );
    return Hero(
      tag: TAG,
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(text: translation.agreement, style: captionStyle),
                TextSpan(text: translation.space, style: captionStyle),
                TextSpan(
                  text: translation.terms,
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launch(translation.termsLink),
                ),
                TextSpan(text: translation.space, style: captionStyle),
                TextSpan(text: translation.agreementAnd, style: captionStyle),
                TextSpan(text: translation.space, style: captionStyle),
                TextSpan(
                  text: translation.privacyPolicy,
                  style: linkStyle,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => _launch(translation.privacyPolicyLink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
