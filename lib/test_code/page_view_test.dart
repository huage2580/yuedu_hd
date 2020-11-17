
import 'package:flutter/material.dart';

class PageViewer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return PageViewerState();
  }

}


class PageViewerState extends State<PageViewer>{
  PageController _controller;
  static const MAX_PAGE = 1999999999;
  static final INIT_PAGE = (MAX_PAGE/2).ceil();
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: INIT_PAGE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: (d){
          Offset offset = d.localPosition;
          print("${offset.dx},${offset.dy}");
        },
        child: Container(
          child: PageView.builder(itemBuilder: (ctx,index){
            if(index == INIT_PAGE + 3){
              return null;
            }
            return Center(
              child: Text("测试$index"),
            );
          },controller: _controller,
            itemCount: MAX_PAGE,
          ),
        ),
      ),
    );
  }

}