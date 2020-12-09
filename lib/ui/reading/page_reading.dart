

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/bookshelf/widget_chapters.dart';
import 'package:yuedu_hd/ui/reading/ReadingWidget.dart';
import 'package:yuedu_hd/ui/reading/event/ChapterChangedEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextPageEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousPageEvent.dart';
import 'package:yuedu_hd/ui/widget/PopupMenu.dart';

class PageReading extends StatefulWidget{

  @override
  _PageReadingState createState() => _PageReadingState();
}

class _PageReadingState extends State<PageReading> {
  final sizeKey = GlobalKey();
  final _styleMenuKey = GlobalKey();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  var showMenuBar = false;
  var initChapterName;
  var currChapterName;
  var chapterChangedCallBack;

  BookInfoBean bookInfo;
  int bookId = -1;

  @override
  void initState() {
    super.initState();
    chapterChangedCallBack = (){
      setState(() {
        currChapterName = ChapterChangedEvent.getInstance().chapterName;
      });
    };
    ChapterChangedEvent.getInstance().addListener(chapterChangedCallBack);
  }

  @override
  Widget build(BuildContext context) {
    var args= ModalRoute.of(context).settings.arguments as Map;
    if(bookId == -1){
      bookId = args['bookId'];
      _fetchBookInfo();
    }
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
            _hideMenuBar();
            PreviousPageEvent.getInstance().emit();
          }else if(tapX > threshold * 2){//下一页
            _hideMenuBar();
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
        },readChapterName: currChapterName,),
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
                              Text(currChapterName??'加载中...',style: TextStyle(color: theme.accentColor,fontSize: 22),),
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
                              IconButton(key: _styleMenuKey,icon:Icon(Icons.font_download_outlined,color: theme.accentColor), onPressed: (){
                                _showStyleMenu(context);
                              }),
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
                    color: theme.canvasColor,
                    child: Text(bookInfo==null?'获取书籍信息...':'${bookInfo.name}[${bookInfo.author}] ${bookInfo.bookUrl}'),
                  )
                ],
              ),
            ),
          );
  }
  
  ///阅读样式调整菜单
  void _showStyleMenu(BuildContext context){
    var theme = Theme.of(context);
    var menu = PopupMenu(context: context,contentHeight: 300,contentWidth: 260,backgroundColor: theme.cardColor,
        child: FlatButton(onPressed: (){print('click!');},child: Text('test'),),
    );
    menu.show(widgetKey: _styleMenuKey);
  }

  void _fetchBookInfo() async{
    bookInfo = await DatabaseHelper().queryBookInfoFromBookIdCombSourceId(bookId,-1);
    setState(() {

    });
  }


  @override
  void dispose() {
    super.dispose();
    ChapterChangedEvent.getInstance().removeListener(chapterChangedCallBack);
  }

  void _switchMenuBar(){
    showMenuBar = !showMenuBar;
    setState(() {
      CupertinoIcons.square_split_1x2_fill;
      CupertinoIcons.square_split_2x1_fill;
      CupertinoIcons.square_favorites_fill;
      CupertinoIcons.book_fill;
    });
  }

  void _nextChapter(){
    _hideMenuBar();
    NextChapterEvent.getInstance().emit();
  }

  void _previousChapter(){
    _hideMenuBar();
    PreviousChapterEvent.getInstance().emit();
  }

  void _hideMenuBar(){
    setState(() {
      showMenuBar = false;
    });
  }
}

//TODO 配置菜单样式