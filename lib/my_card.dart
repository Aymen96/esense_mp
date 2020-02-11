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
            leading: Image.network(
              'https://lh3.googleusercontent.com/proxy/FQukmH_3dB9dhlBXQG8GfsXhkHBk8tiCr_Vwr3oc_QZMKH6PbN8zc34lAMN5kvGuKnpb5NfFId0aNH4Z9SRT2CKxDYlSAp694EwZjpmYFa-7frDLtBxkJ-2Lc9M',
            ),
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
