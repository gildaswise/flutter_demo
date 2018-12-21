import 'package:flutter/material.dart';
import 'package:sala/main.dart';

class ModalNewTweet extends StatefulWidget {
  final Function(Tweet) onSend;

  const ModalNewTweet({Key key, this.onSend}) : super(key: key);

  @override
  _ModalNewTweetState createState() => _ModalNewTweetState();
}

class _ModalNewTweetState extends State<ModalNewTweet> {
  final _usernameController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 16.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: "Username",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _contentController,
            decoration: InputDecoration(
              labelText: "Content",
              border: OutlineInputBorder(),
            ),
          ),
        ),
        ButtonBar(
          children: <Widget>[
            FlatButton.icon(
                icon: Icon(Icons.send),
                label: Text("Enviar"),
                textColor: Colors.green,
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onSend?.call(Tweet(
                    _usernameController.text,
                    _contentController.text,
                  ));
                }),
            FlatButton.icon(
              icon: Icon(Icons.close),
              label: Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        )
      ],
    );
  }
}
