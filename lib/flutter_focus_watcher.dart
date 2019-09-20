/*
(c) Copyright 2019 Serov Konstantin.

Licensed under the MIT license:

    http://www.opensource.org/licenses/mit-license.php

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

library flutter_focus_watcher;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

/*
 * This widget is used to remove TextField focus if a tap occured somewhere else
 * In order for this to work properly, it must be placed inside MaterialApp or
 * WidgetsApp. This is necessary because this widget requires MediaQuery,
 * which is supplied by those two
 * Basically, your app build method should look like this
 *
 @override
 Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FocusWatcher(
          child: MyHomePage(title: 'Flutter Demo Home Page')
      ),
    );
  }
 *
 * BUT! There are some usecases when you want to disallow
 * this behavior, e.g. when you tap on some widget which is not
 * a TextField instance
 * in this case, simply wrap that widget in the IgnoreFocusWatcher and this
 * listener will ignore taps on that
 *
 * The widget will also keep track of a keyboard space and move the whole
 * application up if a focused TextField gets obscured by the keyboard
 * The only additional thing you need to do for it is
 * to set your Scaffold's resizeToAvoidBottomInset to false
 * (in case you use scaffold) and that's it.
 * If you want to change the height of application lift, simply set your
 * preferred value to the FocusWatcher's liftOffset variable.
 * The default value is 15.0. This means the number of points above the
 * keyboard's upper bound
 *
 */

class FocusWatcher extends StatefulWidget {
  final Widget child;
  final double liftOffset;
  final Curve animationCurve;
  final Duration animationDuration;

  FocusWatcher({
    @required this.child,
    this.liftOffset = 15.0,
    this.animationCurve = Curves.easeIn,
    this.animationDuration = const Duration(milliseconds: 300)
  });

  @override
  _FocusWatcherState createState() => _FocusWatcherState();
}

class _FocusWatcherState extends State<FocusWatcher> with SingleTickerProviderStateMixin {

  final Offset defaultOffset = Offset(0, 0);
  double pageY = 0;
  double reverseFrom = 0;
  double textFieldBottom = 0.0;
  AnimationController _controller;
  Animation<double> _animation;
  RenderBox lastRenderBox;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _animation = Tween(begin: 0.0, end: 0.0).animate(
        CurvedAnimation(parent: _controller, curve: widget.animationCurve));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (c, w) {
        return Transform(
          transform: Matrix4.translationValues(0, _animation.value, 0),
          child: LayoutBuilder(
              builder: (BuildContext c, BoxConstraints viewportConstraints) {
                var keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

                if (keyboardHeight > 0.0) {
                  if (textFieldBottom > 0.0) {
                    _moveScreen(textFieldBottom, keyboardHeight + widget.liftOffset, viewportConstraints.maxHeight);
                    textFieldBottom = 0.0;
                  }
                } else {
                  if (pageY != 0.0) {
                    _moveScreen(0, 0, 0);
                    textFieldBottom = 0.0;
                  }
                }
                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: viewportConstraints.maxWidth,
                      maxHeight: viewportConstraints.maxHeight
                  ),
                  child: Listener(
                    onPointerUp: (e) {
                      var rb = context.findRenderObject() as RenderBox;
                      var result = BoxHitTestResult();
                      rb.hitTest(result, position: e.position);

                      // if there any widget in the path that must ignore taps,
                      // stop it right here
                      if (result.path.any((entry) =>
                      entry.target.runtimeType == FocusWatcherIgnoreRenderBox)) {
                        return;
                      }
                      var isEditable = result.path.any(
                              (entry) => entry.target.runtimeType == RenderEditable);

                      var currentFocus = FocusScope.of(context);
                      if (!isEditable) {
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                          lastRenderBox = null;
                        }
                      } else {
                        for (var entry in result.path) {
                          if (entry.target.runtimeType == RenderEditable) {
                            var renderBox = (entry.target as RenderBox);
                            Offset offset = renderBox.localToGlobal(defaultOffset);
                            textFieldBottom = offset.dy + renderBox.size.height - pageY;
                            if (lastRenderBox != renderBox) {
                              setState(() { });
                              lastRenderBox = renderBox;
                            }
                          }
                        }
                      }
                    },
                    child: widget.child,
                  ),
                );
              }),
        );
      },
    );
  }

  void _moveScreen(double textFieldBottom, double keyboardHeight, double screenHeight) {
    double newPageY = 0.0;

    if (keyboardHeight > 0.0) {
      newPageY =  min(0, (screenHeight - textFieldBottom) - keyboardHeight);
      //print("DIST TO PASS ${newPageY}");
    }

    Future.delayed(Duration(milliseconds: 15), () {
      setState(() {
        if (pageY != newPageY) {
          _animation = Tween(begin: pageY, end: newPageY).animate(
              CurvedAnimation(parent: _controller, curve: widget.animationCurve));
          _controller.forward(from: 0);
        }

        pageY = newPageY;
      });
    });
  }
  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

class IgnoreFocusWatcher extends SingleChildRenderObjectWidget {
  final Widget child;

  IgnoreFocusWatcher({@required this.child}) : super(child: child);

  @override
  FocusWatcherIgnoreRenderBox createRenderObject(BuildContext context) {
    return FocusWatcherIgnoreRenderBox();
  }
}

class FocusWatcherIgnoreRenderBox extends RenderPointerListener {}
