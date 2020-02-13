import 'package:flutter/material.dart';
import '../data/text.dart';

class MyArticle extends StatefulWidget {
  final Map<String, dynamic> article;

  MyArticle({this.article});

  @override
  _MyArticleState createState() => _MyArticleState();
}

var text = Padding(
  padding: const EdgeInsets.only(left: 16, top: 12.0, right: 12),
  child: Column(
    children: <Widget>[
      Text(
        longText,
        style: TextStyle(fontSize: 17),
      ),
    ],
  ),
);

class _MyArticleState extends State<MyArticle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 18.0, right: 8),
              child: Text(
                widget.article['abstract'],
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 24.0, right: 8),
              child: Text(
                widget.article['snippet'],
                style: TextStyle(color: Colors.black45, fontSize: 17),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12.0, right: 8),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                          "https://banner2.kisspng.com/20190131/aob/kisspng-ad-blocking-adguard-computer-software-download-mob-5c537e57554f10.6046552315489757033494.jpg"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Authors' name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    "20/02/2020 - 5 Min Read",
                    style: TextStyle(color: Colors.black45),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              width: MediaQuery.of(context).size.width,
              child: Image.network('https://static01.nyt.com/' +
                  widget.article['multimedia'][0]['url']),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 12.0, right: 12),
              child: Column(
                children: <Widget>[
                  Text(
                    widget.article['snippet'],
                    style: TextStyle(fontSize: 17),
                  ),
                  Text(
                    widget.article['lead_paragraph'],
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(
                height: 2.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: AssetImage('assets/nytimes.jpg'),
                ),
                Column(
                  children: <Widget>[
                    Text(
                      "Published in",
                      style: TextStyle(color: Colors.black45),
                    ),
                    Text(widget.article['source']),
                  ],
                ),
                Divider(
                  height: 2.0,
                ),
                OutlineButton(
                  textColor: Colors.blue,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(4.0)),
                  child: Text('Go to source'),
                  borderSide: BorderSide(
                      color: Colors.blue, style: BorderStyle.solid, width: 1),
                  onPressed: () {},
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(
                height: 2.0,
              ),
            ),
            text,
            text,
            text,
            text,
            text,
            text,
            text,
            text,
            text,
            text,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(
                height: 2.0,
              ),
            ),
            Container(
              child: ListTile(
                title: Text(
                  "Give this article a comment...",
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(
                height: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
