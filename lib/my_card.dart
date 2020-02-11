import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String title;
  final String text;
  final bool mark;
  final Function(String) onOpen;
  final Function(String) onMark;
  final Function(String) onDismark;

  MyCard(
      {this.title,
      this.text,
      this.onOpen,
      this.onMark,
      this.onDismark,
      this.mark});

  @override
  Widget build(BuildContext context) {
    return MyCardStateful(
        title: title,
        text: text,
        onOpen: onOpen,
        onMark: onMark,
        onDismark: onDismark,
        mark: mark);
  }
}

class MyCardStateful extends StatefulWidget {
  final String title;
  final String text;
  final bool mark;
  final Function(String) onOpen;
  final Function(String) onMark;
  final Function(String) onDismark;

  MyCardStateful(
      {this.title,
      this.text,
      this.onOpen,
      this.onMark,
      this.onDismark,
      this.mark});

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCardStateful> {
  void _onMarkAsRead() {
    if (!widget.mark) {
      widget.onMark(widget.title);
    } else {
      widget.onDismark(widget.title);
    }
  }

  void _onOpen() {
    widget.onOpen(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
        opacity: widget.mark ? 0.2 : 1.0,
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Image.network(
                  'https://lh3.googleusercontent.com/proxy/FQukmH_3dB9dhlBXQG8GfsXhkHBk8tiCr_Vwr3oc_QZMKH6PbN8zc34lAMN5kvGuKnpb5NfFId0aNH4Z9SRT2CKxDYlSAp694EwZjpmYFa-7frDLtBxkJ-2Lc9M',
                ),
                title: Text(widget.title),
                subtitle: !widget.mark ? Text(widget.text) : SizedBox.shrink(),
                //trailing: Icon(Icons.delete,color: Colors.red,),
              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        !widget.mark ? "Mark as read" : 'Unread',
                        style: TextStyle(color: Colors.pink),
                      ),
                      onPressed: _onMarkAsRead,
                    ),
                    widget.mark
                        ? SizedBox.shrink()
                        : FlatButton(
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
        ));
  }
}
