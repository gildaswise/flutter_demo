import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sala/main.dart';
import 'dart:convert';

class TweetWidget extends StatelessWidget {
  final Tweet tweet;

  const TweetWidget({
    Key key,
    this.tweet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: ListTile(
          onTap: null,
          leading: CircleAvatar(),
          title: Text("@${tweet.username}"),
          subtitle: Text("${tweet.content}"),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<Tweet> tweets;

  const HomePage({Key key, this.tweets}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> _data;

  @override
  void initState() {
    super.initState();
    _http();
  }

  _http() async {
    final client = Client();
    final request = await client.get(
      Uri.https(
        "api.github.com",
        "/users/leonfers",
      ),
    );

    if (request.statusCode == 200) {
      setState(() {
        _data = json.decode(request.body);
      });
    } else {
      print("ih");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _data != null
          ? ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(_data["avatar_url"]),
              ),
              title: Text(_data["login"]),
              subtitle: Text(_data["id"].toString()),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
