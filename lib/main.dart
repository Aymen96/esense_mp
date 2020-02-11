import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import './my_card.dart';
import './article.dart';

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
      title: 'News reader',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Esense Reading Experience'),
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
  List<String> _markedArticles = new List<String>();
  int _currentOpened = 0;

  void onMark(String title) {
    _markedArticles.add(title);
    setState(() {
      _markedArticles = _markedArticles;
    });
  }

  void onDismark(String title) {
    _markedArticles.remove(title);
    setState(() {
      _markedArticles = _markedArticles;
    });
  }

  void onOpenArticle(String current) {
    int counter = 0;
    while (
        counter < articles.length && articles[counter]['abstract'] != current) {
      counter++;
    }
    setState(() {
      _inArticle = true;
      _reading = false;
      _currentOpened = counter;
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
            onMark: onMark,
            onDismark: onDismark,
            mark: _markedArticles.contains(el['abstract']),
          )));
    }
    return listItems;
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
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Earables\' status: connected. Battery level: 30%',
                        style: TextStyle(fontSize: 17),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(
                    height: 2.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Daily Reads',
                        style: Theme.of(context).textTheme.headline,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                ...getList()
              ],
            )
          : SingleChildScrollView(
              child: MyArticle(article: articles[_currentOpened]),
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
