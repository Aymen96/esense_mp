import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String title;
  final String text;
  VoidCallback onOpen;

  MyCard({this.title, this.text, this.onOpen});

  void _onMarkAsRead() {}

  void _onOpen() {
    onOpen();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.amber),
            title: Text("$title"),
            subtitle: Text("$text"),
            //trailing: Icon(Icons.delete,color: Colors.red,),
          ),
          ButtonTheme.bar(
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: Text(
                    "Mark as read",
                    style: TextStyle(color: Colors.pink),
                  ),
                  onPressed: _onMarkAsRead,
                ),
                FlatButton(
                  child: Text(
                    "Open",
                    style: TextStyle(color: Colors.pink),
                  ),
                  onPressed: _onOpen,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
