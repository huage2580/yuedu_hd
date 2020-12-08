

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/reading/ReadingWidget.dart';

class PageReading extends StatefulWidget{

  @override
  _PageReadingState createState() => _PageReadingState();
}

class _PageReadingState extends State<PageReading> {
  final sizeKey = GlobalKey();
  var showMenuBar = false;

  @override
  Widget build(BuildContext context) {
    var args= ModalRoute.of(context).settings.arguments as Map;
    int bookId = args['bookId'];
    String initChapterName = args['initChapterName'];
    var theme = Theme.of(context);
    return Scaffold(
      body: GestureDetector(
        onTapUp: (d){
          var tapX = d.localPosition.dx;
          var width = sizeKey.currentContext.size.width;
          var threshold = width/3;
          if(tapX < threshold){//上一页

          }else if(tapX > threshold * 2){//下一页

          }else{//菜单
            _switchMenuBar();
          }
        },
        child: Stack(
          key: sizeKey,
          children: [
            ReadingWidget(bookId, initChapterName),
            _buildMenuBar(context, theme),
          ],
        ),
      ),
    );
  }

  Visibility _buildMenuBar(BuildContext context, ThemeData theme) {
    return Visibility(
            visible: showMenuBar,
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBar(leading: IconButton(icon: Icon(Icons.close), onPressed: (){
                    Navigator.of(context).pop();
                  }),title: Text('标题'),),
                  Container(
                    width: double.maxFinite,
                    color: theme.cardColor,
                    child: Text('这里是书籍信息'),
                  )
                ],
              ),
            ),
          );
  }

  void _switchMenuBar(){
    showMenuBar = !showMenuBar;
    setState(() {

    });
  }
}