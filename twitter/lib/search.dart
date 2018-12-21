import 'package:flutter/material.dart';

class SearchPage extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return (query.isNotEmpty)
        ? [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => query = '',
            )
          ]
        : null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
        child: LinearProgressIndicator(
      backgroundColor: Colors.red,
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("Sugestão"),
          onTap: () => query = "Sugestão",
        ),
      ],
    );
  }
}
