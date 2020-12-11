import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/book_source/widget_select_source.dart';
import 'package:yuedu_hd/ui/bookshelf/widget_chapters.dart';
import 'package:yuedu_hd/ui/download/BookDownloader.dart';
import 'package:yuedu_hd/ui/reading/ReadingWidget.dart';
import 'package:yuedu_hd/ui/reading/event/ChapterChangedEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextPageEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousPageEvent.dart';
import 'package:yuedu_hd/ui/settings/MoreStyleSettingsMenu.dart';
import 'package:yuedu_hd/ui/widget/PopupMenu.dart';

import 'StyleMenuWidget.dart';

class PageReading extends StatefulWidget {
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

  var orientation = Orientation.landscape;
  var size = Size(-1, -1);//整个手机or窗口的大小

  var _readingWidgetKey = GlobalKey();
  PopupMenu styleMenu;

  @override
  void initState() {
    super.initState();
    //可以竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);

    chapterChangedCallBack = () {
      currChapterName = ChapterChangedEvent.getInstance().chapterName;
      setState(() {});
    };
    ChapterChangedEvent.getInstance().addListener(chapterChangedCallBack);
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context).settings.arguments as Map;
    if (bookId == -1) {
      bookId = args['bookId'];
      _fetchBookInfo();
    }
    if (initChapterName == null) {
      initChapterName = args['initChapterName'];
      if (initChapterName != null) {
        //没指定阅读章节，要从上次阅读加载
        _readingWidgetKey = GlobalKey();
      }
    }
    var theme = Theme.of(context);
    return Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTapUp: (d) {
          var tapX = d.localPosition.dx;
          var width = sizeKey.currentContext.size.width;
          var threshold = width / 3;
          if (tapX < threshold) {
            //上一页
            _hideMenuBar();
            PreviousPageEvent.getInstance().emit();
          } else if (tapX > threshold * 2) {
            //下一页
            _hideMenuBar();
            NextPageEvent.getInstance().emit();
          } else {
            //菜单
            _switchMenuBar();
          }
        },
        child: Stack(
          key: sizeKey,
          children: [
            OrientationBuilder(builder: (ctx, or) {
              if (or != orientation) {
                //横竖屏切换重新渲染阅读页
                _readingWidgetKey = GlobalKey();
                orientation = or;
              }
              if(or == orientation){//window size changed
                var currSize = Size.copy(MediaQuery.of(context).size);
                if(currSize != size){
                  size = currSize;
                  _readingWidgetKey = GlobalKey();
                }
              }
              return ReadingWidget(
                bookId,
                initChapterName,
                key: _readingWidgetKey,
              );
            }),
            _buildMenuBar(context, theme),
          ],
        ),
      ),
      endDrawerEnableOpenDragGesture: false,
      endDrawer: Container(
        width: 400,
        child: Drawer(
          child: ChaptersWidget(
            bookId,
            (bean) {
              initChapterName = bean.name;
              _readingWidgetKey = GlobalKey();
              setState(() {
                showMenuBar = false;
                //选取章节
              });
            },
            readChapterName: currChapterName,
          ),
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
            Container(
              color: theme.primaryColor,
              padding: EdgeInsets.all(8),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                        icon: Icon(Icons.close),
                        color: theme.accentColor,
                        iconSize: 28,
                        onPressed: () {
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
                        IconButton(
                            icon: Icon(Icons.chevron_left_outlined,
                                color: theme.accentColor),
                            onPressed: () {
                              _previousChapter();
                            }),
                        OrientationBuilder(
                         builder:(ctx,orn){
                           return  Container(
                           constraints: BoxConstraints(maxWidth:orientation == Orientation.landscape?400:80),
                           child: Text(
                           currChapterName ?? '加载中...',
                           style: TextStyle(
                           color: theme.accentColor, fontSize: 22),
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                           ));
                         },
                        ),
                        IconButton(
                            icon: Icon(Icons.chevron_right_outlined,
                                color: theme.accentColor),
                            onPressed: () {
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
                        IconButton(
                            icon: Icon(CupertinoIcons.repeat,
                                color: theme.accentColor),
                            onPressed: () {
                              _showSourceSelectDialog(context);
                            }),
                        IconButton(
                            icon: Icon(Icons.cloud_download_outlined,
                                color: theme.accentColor),
                            onPressed: () {
                              BookDownloader.getInstance().startDownload(bookId);
                              BotToast.showText(text:"开始缓存");
                            }),
                        IconButton(
                            key: _styleMenuKey,
                            icon: Icon(Icons.font_download_outlined,
                                color: theme.accentColor),
                            onPressed: () {
                              _showStyleMenu(context);
                            }),
                        IconButton(
                            icon:
                                Icon(Icons.menu_book, color: theme.accentColor),
                            onPressed: () {
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
              child: Text(bookInfo == null
                  ? '获取书籍信息...'
                  : '${bookInfo.name}[${bookInfo.author}] $currChapterName ${bookInfo.bookUrl}',maxLines: 1,overflow: TextOverflow.ellipsis,),
            )
          ],
        ),
      ),
    );
  }

  ///阅读样式调整菜单
  void _showStyleMenu(BuildContext context) {
    var theme = Theme.of(context);
    styleMenu = PopupMenu(
        context: context,
        contentHeight: 350,
        contentWidth: 260,
        backgroundColor: theme.cardColor,
        child: GestureDetector(
            onTap: () {
              print('menu click');
            },
            behavior: HitTestBehavior.translucent,
            child: _buildStyleMenu(context)));
    styleMenu.show(widgetKey: _styleMenuKey);
  }

  Widget _buildStyleMenu(BuildContext context) {
    return StyleMenu(
      onReadingStyleChanged: () {
        _readingWidgetKey = GlobalKey();
        setState(() {});
      },
      onMoreClick: (){
        styleMenu.dismiss();
        showMenuBar = false;
        _showMoreSettings(context);
      },
    );
  }

  void _showMoreSettings(BuildContext context){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return Scaffold(
        appBar: AppBar(title: Text('阅读设置'),),
        body: SingleChildScrollView(child: MoreStyleSettingsMenu()),
      );
    })).then((value){
      showMenuBar = false;
      _readingWidgetKey = GlobalKey();
      setState(() {

      });
    });
  }

  void _showSourceSelectDialog(BuildContext context) async {
    var result = await showDialog(
        context: context,
        child: Dialog(
          child: WidgetSelectSource(bookId),
        ));
    if (result != null) {
      //换源以后重新加载
      initChapterName = null;
      _readingWidgetKey = GlobalKey();
      _hideMenuBar();
    }
  }

  void _fetchBookInfo() async {
    bookInfo =
        await DatabaseHelper().queryBookInfoFromBookIdCombSourceId(bookId, -1);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    ChapterChangedEvent.getInstance().removeListener(chapterChangedCallBack);
  }

  void _switchMenuBar() {
    showMenuBar = !showMenuBar;
    setState(() {});
  }

  void _nextChapter() {
    _hideMenuBar();
    NextChapterEvent.getInstance().emit();
  }

  void _previousChapter() {
    _hideMenuBar();
    PreviousChapterEvent.getInstance().emit();
  }

  void _hideMenuBar() {
    setState(() {
      showMenuBar = false;
    });
  }
}
