import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import './my_card.dart';
import './article.dart';
import 'package:esense_flutter/esense.dart';
import './custom_dialog.dart';

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

  // TODO: look into this
  String _deviceName = 'Unknown';
  double _voltage = -1;
  String _deviceStatus = '';
  bool sampling = false;
  String _event = '';
  String _button = '';

  // the name of the eSense device to connect to -- change this to your own device.
  String eSenseName = 'eSense-0264';
  bool _deviceConnected = false;

  // Dialog modal data
  Icon _icon;
  String _title;
  String _message;
  VoidCallback _handleAction;

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

  Future<void> _connectToESense() async {
    // if you want to get the connection events when connecting, set up the listener BEFORE connecting...
    ESenseManager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');

      // when we're connected to the eSense device, we can start listening to events from it
      if (event.type == ConnectionType.connected) {
        _listenToESenseEvents();
        _deviceConnected = true;
      }

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            _deviceConnected = true;
            askForCalibration();
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            _deviceConnected = false;
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            _deviceConnected = false;

            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';

            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            _deviceConnected = false;

            break;
        }
      });
    });

    _deviceConnected = await ESenseManager.connect(eSenseName);
  }

  void _listenToESenseEvents() async {
    ESenseManager.eSenseEvents.listen((event) {
      print('ESENSE event: $event');

      setState(() {
        switch (event.runtimeType) {
          case DeviceNameRead:
            _deviceName = (event as DeviceNameRead).deviceName;
            break;
          case BatteryRead:
            _voltage = (event as BatteryRead).voltage;
            break;
          case ButtonEventChanged:
            _button = (event as ButtonEventChanged).pressed
                ? 'pressed'
                : 'not pressed';
            break;
          case AccelerometerOffsetRead:
            // TODO

            break;
          case AdvertisementAndConnectionIntervalRead:
            // TODO
            break;
          case SensorConfigRead:
            // TODO

            break;
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10),
        (timer) async => await ESenseManager.getBatteryVoltage());

    // wait 2, 3, 4, 5, ... secs before getting the name, offset, etc.
    // it seems like the eSense BTLE interface does NOT like to get called
    // several times in a row -- hence, delays are added in the following calls
    Timer(
        Duration(seconds: 2), () async => await ESenseManager.getDeviceName());
    Timer(Duration(seconds: 3),
        () async => await ESenseManager.getAccelerometerOffset());
    Timer(
        Duration(seconds: 4),
        () async =>
            await ESenseManager.getAdvertisementAndConnectionInterval());
    Timer(Duration(seconds: 5),
        () async => await ESenseManager.getSensorConfig());
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

  void alertUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: _title,
        description: _message,
        onConnect: _handleAction,
        buttonText: "skip",
      ),
    );
  }

  void askForCalibration() {
    setState(() {
      _title = 'Calibrate';
      _message = 'Please hold your head still for 5 seconds';
      _handleAction = startCalibration;
    });
    alertUser();
  }

  void startCalibration() {}

  @override
  void initState() {
    super.initState();
    setState(() {
      _title = "Make connection";
      _message = "Please connect to your eSense Earables.";
      _icon = Icon(Icons.audiotrack);
      _handleAction = _connectToESense;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => alertUser());
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
            !_deviceConnected
                ? IconButton(
                    icon: Icon(Icons.audiotrack, color: Colors.white),
                    onPressed: alertUser)
                : SizedBox.shrink(),
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
                        'Earables\' status: ${_deviceConnected ? 'connected' : 'not connected'}. Battery level: ${_deviceConnected ? '30%' : '-'}',
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
