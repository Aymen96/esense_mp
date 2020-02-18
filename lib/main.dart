import 'dart:async';
import 'dart:convert';

import 'package:esense_flutter/esense.dart';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

import './widgets/my_card.dart';
import './widgets/my_article.dart';
import './widgets/my_dialog.dart';

var articles;
const emptyWidget = SizedBox.shrink();

void main() async {
  // Get articles for the chosen news API
  String url =
      'https://api.nytimes.com/svc/search/v2/articlesearch.json?q=internet+of+things&api-key=U1khtqk3q8mHmO1FOJD4twU3eoiGuLUJ';
  Response response = await get(url);
  if (response.statusCode == 200) {
    String body = response.body;
    articles = json.decode(body)['response']['docs'];
  }
  // render app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Daily Reads',
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
  IconData _icon = Icons.warning;
  String _title;
  String _message;
  Function(VoidCallback) _handleAction;
  String _modalCaller = 'other';
  String _buttonLabel = 'connect';
  List<List<int>> _gyros = [];
  List<List<double>> _stableGyros = [];
  bool _scroll = true;

  // User Interaction with App
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

  void goBackToList() {
    setState(() {
      _inArticle = false;
      _reading = false;
    });
  }

  // eSense earables urils
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
            alertConnectionLoss();
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            _deviceConnected = false;
            retryConnection();
            break;
        }
      });
    });

    _deviceConnected = await ESenseManager.connect(eSenseName);
  }

  StreamSubscription sub;

  void _listenToESenseEvents() async {
    sub = ESenseManager.eSenseEvents.listen((event) {
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
        }
      });
    });

    _getESenseProperties();
  }

  void _getESenseProperties() async {
    // get the battery level every 10 secs
    Timer.periodic(Duration(seconds: 10), (timer) async {
      if (_deviceConnected) {
        await ESenseManager.getBatteryVoltage();
      }
    });

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

  StreamSubscription subscription;

  void _startListenToSensorEvents() async {
    // subscribe to sensor event from the eSense device
    subscription = ESenseManager.sensorEvents.listen((event) {
      setState(() {
        _event = event.toString();
        _gyros.add(event.gyro);
      });
    });
    setState(() {
      sampling = true;
    });
  }

  void _pauseListenToSensorEvents() async {
    subscription.cancel();
    List<double> smoothedGyros = [0, 0, 0];
    _gyros.forEach((g) {
      smoothedGyros[0] = smoothedGyros[0] + (g[0] / _gyros.length);
      smoothedGyros[1] = smoothedGyros[1] + (g[1] / _gyros.length);
      smoothedGyros[2] = smoothedGyros[2] + (g[2] / _gyros.length);
    });
    setState(() {
      sampling = false;
      if (smoothedGyros[0] != 0) _stableGyros.add(smoothedGyros);
    });
  }

  void dispose() {
    if (sampling) _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    super.dispose();
  }

  void askForCalibration() {
    setState(() {
      _title = 'Calibrate';
      _message =
          'Please hold your head still in reading position for 5 seconds';
      _handleAction = startCalibration;
      _modalCaller = 'calibrator';
      _buttonLabel = 'Calibrate';
      _icon = Icons.hearing;
    });
    alertUser();
  }

  void startCalibration(VoidCallback callback) {
    int counter = 0;
    Timer.periodic(Duration(milliseconds: 1200), (timer) async {
      counter++;
      _startListenToSensorEvents();
      Timer(Duration(milliseconds: 1100), () {
        _pauseListenToSensorEvents();
      });
      if (counter >= 5) {
        print('timer canceled');
        print(_stableGyros);
        timer.cancel();
      }
    });
    new Timer(const Duration(seconds: 5), () {
      if (_stableGyros == []) {
        setState(() {
          _title = 'Calibration Problem occured';
          _message =
              'Please hold your head still in reading position for 5 seconds AGAIN';
          _handleAction = startCalibration;
          _modalCaller = 'calibrator';
          _buttonLabel = 'Calibrate';
          _icon = Icons.sentiment_dissatisfied;
        });
        alertUser();
      } else {
        callback();
        setState(() {
          _title = 'Enjoy';
          _message = 'Head movement will scroll articles up and down.';
          _handleAction = (VoidCallback callback) {
            callback();
          };
          _modalCaller = 'other';
          _buttonLabel = null;
          _icon = Icons.sentiment_very_satisfied;
        });
        alertUser();
      }
    });
  }

  void makeConnection(VoidCallback callback) {
    _connectToESense();
    callback();
  }

  retryConnection() {
    setState(() {
      _title = 'Device not found';
      _message =
          'Make sure your earables & bluetooth on your phone are on and retry again.';
      _handleAction = (VoidCallback callback) async {
        _deviceConnected = await ESenseManager.connect(eSenseName);
        callback();
      };
      _buttonLabel = 'Retry';
      _deviceConnected = false;
      _icon = Icons.headset_off;
    });
    if (sampling) _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    alertUser();
  }

  void alertConnectionLoss() {
    setState(() {
      _title = 'Connection lost';
      _message =
          'Connection to the ${eSenseName} lost. Please make sure they are on and try a new connection.';
      _handleAction = (VoidCallback callback) async {
        _deviceConnected = await ESenseManager.connect(eSenseName);
        callback();
      };
      _buttonLabel = 'connect';
      _deviceConnected = false;
      _icon = Icons.warning;
    });
    if (sampling) _pauseListenToSensorEvents();
    ESenseManager.disconnect();
    alertUser();
  }

  // Scroll actions on head movement event listened
  void scrollDown() {
    if (_inArticle && _scroll) {
      double offset = _controller.offset + 300.0;
      _controller.animateTo(offset,
          duration: Duration(seconds: 1), curve: Curves.easeInOut);
    }
  }

  void scrollUp() {
    if (_inArticle && _scroll) {
      double offset = _controller.offset - 300.0;
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
    if (_reading) {
      int times = 0;
      List<int> gyZ = [];
      subscription = ESenseManager.sensorEvents.listen((event) {
        setState(() {
          _event = event.toString();
          gyZ.add(event.gyro[2]);
          times++;
          if (times >= 10) {
            double mean = 0;
            gyZ.forEach((n) {
              mean += n / gyZ.length;
            });
            if (mean > _stableGyros[0][2] + 500) {
              scrollUp();
              print('up');
              print(mean);
              disableScroll();
            } else if (mean < _stableGyros[0][2] - 500) {
              scrollDown();
              print('down');
              print(mean);
              disableScroll();
            }
            times = 0;
            gyZ = [];
          }
        });
      });
    } else {
      subscription.cancel();
    }
  }

  void disableScroll() {
    setState(() {
      _scroll = false;
    });
    Timer(Duration(milliseconds: 2000), () {
      setState(() {
        _scroll = true;
      });
    });
  }

  // rendering utils
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

  void alertUser() {
    showDialog(
        context: context,
        builder: (context) {
          bool _clicked = false;
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
              return CustomDialog(
                  title: _title,
                  description: _message,
                  handleAction: _handleAction,
                  caller: _modalCaller,
                  onClick: () {
                    setState(() {
                      _clicked = !_clicked;
                    });
                  },
                  clicked: _clicked,
                  buttonLabel: _buttonLabel,
                  customIcon: _icon);
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _title = "Make connection";
      _message = "Please connect to your eSense Earables.";
      _icon = Icons.headset;
      _handleAction = makeConnection;
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
                : emptyWidget,
            Text(widget.title),
            !_deviceConnected
                ? IconButton(
                    icon: Icon(Icons.headset, color: Colors.white),
                    onPressed: alertUser)
                : emptyWidget,
            _deviceConnected
                ? IconButton(
                    icon: Icon(Icons.not_interested, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _reading = false;
                        _stableGyros = [];
                        _deviceConnected = false;
                      });
                      sub.cancel();
                      ESenseManager.disconnect();
                    })
                : emptyWidget, // empty widget
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
          : emptyWidget,
    );
  }
}
