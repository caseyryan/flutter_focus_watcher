library flutter_focus_watcher;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/*
 * This widget is used to remove TextField focus if a tap occured somewhere else
 * You need to simply wrap your whole app with this and that's it
 * @override
    Widget build(BuildContext context) {
      return FocusWatcher(
        child: MaterialApp(
          title: 'App',
          home: MyHomePage(title: 'App'),
        ),
      );
    }
 *
 * BUT! There are some use cases when you want to disallow
 * an unfocus when you tap on some widget which is not a TextField instance
 * in this case, simply wrap that widget with an IgnoreFocusWatcher and this
 * listener will ignore taps on that :)
 *
 */

class FocusWatcher extends StatelessWidget {

  final Widget child;
  FocusWatcher({@required this.child});

  @override
  Widget build(BuildContext context) {

//    print("RENDER OBJECT ${context.findRenderObject()}");
    return Listener(
      onPointerUp: (e) {
        var renderBox = context.findRenderObject() as RenderBox;
        var result = BoxHitTestResult();
        renderBox.hitTest(result, position: e.position);
        var isEditable = result.path.any((entry) => entry.target.runtimeType == RenderEditable);
//        print("PATH ${result.path}");
        if (!isEditable) {
          var ignoring = result.path.any((entry) => entry.target.runtimeType == FocusWatcherIgnoreRenderBox);
          if (ignoring) return;
          var currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        }
      },
      child: child,
    );
  }
}

///
class IgnoreFocusWatcher extends SingleChildRenderObjectWidget {
  final Widget child;
  IgnoreFocusWatcher({@required this.child}) : super(child : child);

  @override
  FocusWatcherIgnoreRenderBox createRenderObject(BuildContext context) {
    return FocusWatcherIgnoreRenderBox();
  }
}
class FocusWatcherIgnoreRenderBox extends RenderPointerListener {}