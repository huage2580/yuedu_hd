

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class WheelScroll4Desktop extends StatelessWidget{
  Widget child;
  ScrollController scrollController;
  Timer? _timer = null;

  WheelScroll4Desktop({required this.child,required this.scrollController});

  @override
  Widget build(BuildContext context) {
    if(!Platform.isWindows){
      return child;
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (notification){
        print(notification);
        return false;
      },
      child: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            if(!Platform.isWindows){
              return;
            }
            if(scrollController.position.pixels > 0){
              return;
            }
            if(pointerSignal.scrollDelta.dy > 0){
              return;
            }
            print("position-> ${scrollController.position}");
            //handle scroll event
            print(pointerSignal.scrollDelta);
            final dy = pointerSignal.scrollDelta.dy;
            if(_timer == null){
              ScrollStartNotification(metrics: _makeMetrics(), context: context,dragDetails: DragStartDetails(sourceTimeStamp: Duration(milliseconds: 1),globalPosition: Offset(10, 10),localPosition: Offset(0, 0),kind: PointerDeviceKind.mouse)).dispatch(context);
              UserScrollNotification(metrics: _makeMetrics(), context: context, direction: ScrollDirection.forward).dispatch(context);
              _endScroll(context);
            }else{
              // var animTimer = Timer
              OverscrollNotification(metrics: _makeMetrics(), context: context, overscroll: dy).dispatch(context);
              _endScroll(context);
            }

            // for(var i=0;i<10;i++){
            //   OverscrollNotification(metrics: _makeMetrics(), context: context, overscroll: -20).dispatch(context);
            // }


          }
        },
        child: child,
      ),
    );
  }

  void _endScroll(BuildContext context){
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: 1000), (){
      ScrollEndNotification(metrics: _makeMetrics(), context: context).dispatch(context);
      UserScrollNotification(metrics: _makeMetrics(), context: context, direction: ScrollDirection.idle).dispatch(context);
      _timer = null;
    });
  }

  FixedScrollMetrics _makeMetrics(){
    return FixedScrollMetrics(minScrollExtent: 0, maxScrollExtent: 0, pixels: 0, viewportDimension: scrollController.position.viewportDimension, axisDirection: AxisDirection.down);
  }


}