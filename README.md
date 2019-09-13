## Flutter Focus Watcher
A simple hacky library used to "unfocus" Flutter's built-in TextFields and hide a software keyboard
when a user taps on empty space or some other Widget that is not another TextField.
For some reason, this basic functionality isn't supported by Flutter out of the box, which is kind of  
frustrating. So, as a temporary solution one might use my library. I hope Flutter team will add this
feature natively in future releases


It's very easy to use. You may add it as a library or simply copy 
*flutter_focus_watcher.dart* into your project. It doesn't have any external dependencies

Then simply wrap your whole app with FocusWatcher widget like this:

```dart 
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
...
```  
And it will do the rest. 


![alt gif](https://github.com/caseyryan/flutter_focus_catcher/blob/master/example/focus_watcher.gif?raw=true)


In case you want to exclude some widget from this workflow, simply wrap that widget with 
```dart
@override
Widget build(BuildContext context) {
return IgnoreFocusWatcher(
  child: ...your widget
);
}
```
And this widget will be ignored by FocusWatcher