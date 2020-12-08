

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/bookshelf/widget_chapters.dart';
import 'package:yuedu_hd/ui/reading/ReadingWidget.dart';
import 'package:yuedu_hd/ui/reading/event/NextChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextPageEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousPageEvent.dart';

class PageReading extends StatefulWidget{

  @override
  _PageReadingState createState() => _PageReadingState();
}

class _PageReadingState extends State<PageReading> {
  final sizeKey = GlobalKey();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var showMenuBar = false;
  var initChapterName;

  @override
  Widget build(BuildContext context) {
    var args= ModalRoute.of(context).settings.arguments as Map;
    int bookId = args['bookId'];
    if(initChapterName == null){
      initChapterName = args['initChapterName'];
    }
    var theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTapUp: (d){
          var tapX = d.localPosition.dx;
          var width = sizeKey.currentContext.size.width;
          var threshold = width/3;
          if(tapX < threshold){//上一页
            PreviousPageEvent.getInstance().emit();
          }else if(tapX > threshold * 2){//下一页
            NextPageEvent.getInstance().emit();
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
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Drawer(
        child: ChaptersWidget(bookId,(bean){
          initChapterName = bean.name;
          setState(() {
            showMenuBar = false;
            //选取章节
          });
        }),
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
                  Container(
                    color: theme.primaryColor,
                    padding: EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(icon: Icon(Icons.close),color: theme.accentColor,iconSize: 28, onPressed: (){
                            Navigator.of(context).pop();
                          }),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.chevron_left_outlined,color: theme.accentColor), onPressed: (){
                                _previousChapter();
                              }),
                              Text('第XXX章节',style: TextStyle(color: theme.accentColor,fontSize: 22),),
                              IconButton(icon: Icon(Icons.chevron_right_outlined,color: theme.accentColor), onPressed: (){
                                _nextChapter();
                              }),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(icon: Icon(Icons.cloud_download_outlined,color: theme.accentColor), onPressed: (){}),
                              IconButton(icon: Icon(Icons.font_download_outlined,color: theme.accentColor), onPressed: (){}),
                              IconButton(icon: Icon(Icons.menu_book,color: theme.accentColor), onPressed: (){
                                _scaffoldKey.currentState.openEndDrawer();
                              }),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
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

  void _nextChapter(){
    NextChapterEvent.getInstance().emit();
  }

  void _previousChapter(){
    PreviousChapterEvent.getInstance().emit();
  }
}