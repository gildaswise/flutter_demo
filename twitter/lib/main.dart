import 'package:flutter/material.dart';
import 'package:sala/home.dart';
import 'package:sala/modal.dart';
import 'package:sala/search.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Twitter'),
    );
  }
}

class Tweet {
  final String username;
  final String content;

  Tweet(this.username, this.content);
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _pageController = PageController();

  List<Tweet> _tweets = [
    Tweet("rogerio410", "Perfeito."),
  ];

  void _addTweet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ModalNewTweet(onSend: (tweet) {
            setState(() {
              _tweets.add(tweet);
            });
          }),
    );
  }

  int _currentIndex = 0;

  _onNavigationTap(int position) {
    _pageController
        .animateToPage(
      position,
      curve: Curves.ease,
      duration: Duration(
        milliseconds: 200,
      ),
    )
        .then((value) {
      setState(() {
        _currentIndex = position;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => showSearch(
                  context: context,
                  delegate: SearchPage(),
                ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          HomePage(tweets: _tweets),
          Center(child: Text("Notifications")),
          Center(child: Text("Messages")),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.blue,
            icon: Icon(Icons.home),
            title: Text("Home"),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.red,
            icon: Icon(Icons.notifications),
            title: Text("Notifications"),
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.amber,
            icon: Icon(Icons.message),
            title: Text("Messages"),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTweet,
        child: Icon(Icons.add),
      ),
    );
  }
}
