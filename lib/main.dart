import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import './my_card.dart';
import './text.dart';

var articles;

void main() async {
  // make GET request
  String url =
      'https://api.nytimes.com/svc/search/v2/articlesearch.json?q=internet+of+things&api-key=U1khtqk3q8mHmO1FOJD4twU3eoiGuLUJ';
  Response response = await get(url);
  if (response.statusCode == 200) {
    String body = response.body;
    var docs = json.decode(body)['response']['docs'];
    articles = docs;
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _reading = false;
  bool _inArticle = false;
  var _controller = ScrollController(initialScrollOffset: 0.0);
  List<String> _marked_articles = new List<String>();
  String _current_opened;

  void OnMark(String title) {
    _marked_articles.add(title);
    setState(() {
      _marked_articles = _marked_articles;
    });
  }

  void onDismark(String title) {
    _marked_articles.remove(title);
    setState(() {
      _marked_articles = _marked_articles;
    });
  }

  void onOpenArticle(String current) {
    setState(() {
      _inArticle = true;
      _reading = false;
      _current_opened = current;
    });
  }

  void scrollDown() {
    if (_inArticle && _reading) {
      double offset = _controller.offset + 500.0;
      _controller.animateTo(offset,
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  void scrollUp() {
    if (_inArticle && _reading) {
      double offset = _controller.offset - 500.0;
      if (offset < 0) {
        offset = 0.0;
      }
      _controller.animateTo(offset,
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  void _startReading() {
    setState(() {
      _inArticle = true;
      _reading = !_reading;
    });
  }

  List<Widget> getList() {
    List<Widget> listItems = new List<Widget>();
    if (articles != null) {
      articles.forEach((el) => listItems.add(MyCard(
            title: el['abstract'],
            text: el['snippet'],
            onOpen: onOpenArticle,
            onMark: OnMark,
            onDismark: onDismark,
            mark: _marked_articles.contains(el['abstract']),
          )));
    }
    return listItems;
  }

  Widget getArticleView() {
    return Text(long_text + long_text + long_text);
  }

  void goBackToList() {
    setState(() {
      _inArticle = false;
      _reading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            _inArticle
                ? BackButton(
                    onPressed: goBackToList,
                  )
                : Text(''),
            Text(widget.title),
          ],
        ),
      ),
      body: !_inArticle
          ? ListView(
              padding: const EdgeInsets.all(8),
              children: getList(),
            )
          : SingleChildScrollView(
              child: getArticleView(),
              controller: _controller,
            ),
      floatingActionButton: _inArticle
          ? FloatingActionButton(
              onPressed: _startReading,
              tooltip: 'Start Reading',
              child: Icon(_reading ? Icons.chrome_reader_mode : Icons.book))
          : Text(''),
    );
  }
}
