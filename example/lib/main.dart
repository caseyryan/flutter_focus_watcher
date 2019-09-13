import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        home: MyHomePage(title: 'Focus watcher test'),
      ),
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

  Widget _getTextField({String hintText = ''}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        // Used instead of InputDecorator because it's way too
        // buggy in current versions of Flutter
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.green, width: 2, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(6))),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: TextField(
            decoration: InputDecoration(
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.all(5),
                border: InputBorder.none,
                hintText: hintText),
            style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1),
          ),
        ),
      ),
    );
  }

  Widget _getButton({bool ignorFocusWatcher = false}) {
    var button = Padding(
      padding: const EdgeInsets.all(8.0),
      child: LimitedBox(
        maxHeight: 45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: OutlineButton(
                borderSide: BorderSide(width: 2, style: BorderStyle.solid, color: Colors.green),
                color: Colors.yellow,
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(6.0)),
                onPressed: () {

                },
                child: Text(
                  ignorFocusWatcher ? "I will not unfocus TextField" : "But I will, hahahaha ^^",
                  style: TextStyle(
                    fontSize: 18
                  ),
                ),
//                padding: EdgeInsets.all(8.0),
              ),
            ),
          ],
        ),
      ),
    );

    if (ignorFocusWatcher) {
      return IgnoreFocusWatcher(
        child: button
      );
    }
    return button;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _getTextField(hintText: 'Select me'),
          _getTextField(hintText: 'Or me. And a keyboard will stay'),
          _getButton(),
          _getButton(ignorFocusWatcher: true),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Tap on a TextField to focus it. "
              "Tap somwhere else except for 'Keep Focus' "
              "button and another TextField to unfocus",
            ),
          ),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
