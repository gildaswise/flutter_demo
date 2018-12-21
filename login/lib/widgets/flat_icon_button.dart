import 'package:flutter/material.dart';

class FlatIconButton extends StatelessWidget {
  final Icon icon;
  final Text label;
  final Function onPressed;

  const FlatIconButton({Key key, this.onPressed, this.icon, this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: () => this.onPressed(),
      color: Colors.white,
      elevation: 0.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          this.icon,
          SizedBox(width: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: this.label,
          ),
        ],
      ),
    );
  }
}
