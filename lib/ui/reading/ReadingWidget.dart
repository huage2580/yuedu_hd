
import 'dart:collection';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_content_helper.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/reading/DisplayConfig.dart';
import 'package:yuedu_hd/ui/reading/DisplayPage.dart';
import 'package:yuedu_hd/ui/reading/DisplayCache.dart';
import 'package:yuedu_hd/ui/reading/PageBreaker.dart';
import 'package:yuedu_hd/ui/reading/event/ChapterChangedEvent.dart';
import 'package:yuedu_hd/ui/reading/event/ReloadEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/NextPageEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousChapterEvent.dart';
import 'package:yuedu_hd/ui/reading/event/PreviousPageEvent.dart';

class ReadingWidget extends StatefulWidget{
  final int bookId;
  final String initChapterName;


  ReadingWidget(this.bookId, this.initChapterName,{key}):super(key: key);

  @override
  _ReadingWidgetState createState() => _ReadingWidgetState();
}

class _ReadingWidgetState extends State<ReadingWidget> {
  static const MAX_PAGE = 1999999999;
  static final INIT_PAGE = (MAX_PAGE/2).ceil();


  var tocHelper = BookTocHelper.getInstance();
  var contentHelper = BookContentHelper.getInstance();
  var chaptersList = List<BookChapterBean>();
  var currChapterIndex = 0;
  var initChapterId = -1;
  var initChapterName;//章节名
  var initReadPage = 1;//阅读的章节页码，章节内分页，从1开始
  var displayPageList = LinkedHashMap<int,DisplayPage>();//页码对应显示页面

  var sizeKey = GlobalKey();
  var size = Size(-1, -1);

  PageController _controller;
  var firstPage = INIT_PAGE;

  BookInfoBean bookInfoBean;

  var reloadCallBack;
  var nextChapterCallBack;
  var previousChapterCallBack;
  var nextPageCallBack;
  var previousPageCallBack;

  var errorTips;

  @override
  void initState() {
    _controller = PageController(initialPage: INIT_PAGE);
    Future.delayed(Duration(milliseconds: 400),(){
      DisplayCache.getInstance().clear();
      _setupData();
    });
    //事件监听
    reloadCallBack = () {
      var errorPage = DisplayCache.getInstance().get(ReloadEvent.getInstance().pageIndex);
      print('重新加载...${ReloadEvent.getInstance().pageIndex}');
      _loadChapter(errorPage.chapterIndex, errorPage.viewPageIndex, errorPage.fromEnd);
    };
    ReloadEvent.getInstance().addListener(reloadCallBack);
    nextChapterCallBack = (){
      _nextChapter();
    };
    NextChapterEvent.getInstance().addListener(nextChapterCallBack);
    previousChapterCallBack = (){
      _previousChapter();
    };
    PreviousChapterEvent.getInstance().addListener(previousChapterCallBack);
    nextPageCallBack = (){
      var target = _controller.page.ceil() + 1;
      if(DisplayCache.getInstance().get(target)!=null){
        _controller.animateToPage(target,duration: Duration(milliseconds: 300),curve: Curves.ease);
      }
    };
    NextPageEvent.getInstance().addListener(nextPageCallBack);
    previousPageCallBack = (){
      var target = _controller.page.ceil() - 1;
      if(DisplayCache.getInstance().get(target)!=null){
        _controller.animateToPage(target,duration: Duration(milliseconds: 300),curve: Curves.ease);
      }
    };
    PreviousPageEvent.getInstance().addListener(previousPageCallBack);


    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sizeKey,
      child: Stack(
        children: [
          Center(
            child: Text(errorTips??"(●'◡'●)\n加载中..."),
          ),
          SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: PageView.builder(itemBuilder: (ctx,index){
              if(index < firstPage){
                return _buildErrorIndex();
              }
              return DisplayCache.getInstance().get(index);
            },controller: _controller,
              itemCount: MAX_PAGE,onPageChanged: (i){
                Future.delayed(Duration(milliseconds: 500),(){
                  notifyPageChanged(i);
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();
    DisplayCache.getInstance().clear();
    ReloadEvent.getInstance().removeListener(reloadCallBack);
    NextChapterEvent.getInstance().removeListener(nextChapterCallBack);
    PreviousChapterEvent.getInstance().removeListener(previousChapterCallBack);
    NextPageEvent.getInstance().removeListener(nextPageCallBack);
    PreviousPageEvent.getInstance().removeListener(previousPageCallBack);
  }

  Widget _buildErrorIndex(){
    DisplayConfig config = DisplayConfig.getDefault();
    return Container(
      color: Color(config.backgroundColor),
      child: Center(
        child: Text('没有了啦'),
      ),
    );
  }


  void _setupData() async{
    size = Size.copy(sizeKey.currentContext.size);
    print(size);
    bookInfoBean = await _fetchBookInfo();
    if(widget.initChapterName == null){
      initChapterName = bookInfoBean.lastReadChapter;
      initReadPage = bookInfoBean.lastReadPage;
    }else{
      initChapterName = widget.initChapterName;
      initReadPage = 1;
    }
    await _fetchChapters();
  }

  dynamic _fetchBookInfo() async{
    return DatabaseHelper().queryBookById(widget.bookId);
  }

  dynamic _fetchChapters() async{
    //只从数据库获取目录
    var chapters = await tocHelper.getChapterListOnlyDB(widget.bookId);
    chaptersList.clear();
    chaptersList.addAll(chapters);
    _onChaptersLoad();
  }

  ///目录加载完成
  void _onChaptersLoad() async{
    if(chaptersList.isEmpty){
      setState(() {
        errorTips = "本地章节为空，正在获取网络数据...";
      });
      //从网络获取章节
      chaptersList = await tocHelper.updateChapterList(widget.bookId, -1).catchError((e){
        setState(() {
          errorTips = "章节加载失败，请重试或换源";
        });
      });
      if(chaptersList == null || chaptersList.isEmpty){
        setState(() {
          errorTips = "章节加载失败，请重试或换源";
        });
        return;
      }
    }
    //当前阅读的章节，找到章节id
    for(var i =0;i<chaptersList.length;i++){
      var value = chaptersList[i];
      if(value.name == initChapterName){
        initChapterId = value.id;
        currChapterIndex =i;
        break;
      }
    }

    if(initChapterId == -1){
      initChapterId = chaptersList[0].id;
      currChapterIndex = 0;
    }
    //获取当前章节内容
    var splitPages = await _loadChapter(currChapterIndex,INIT_PAGE,false);
    //加载成功跳转页码
    var offsetPage = 0;
    if(splitPages > 0){
      offsetPage = min(initReadPage -1, splitPages - 1);
      _controller.jumpToPage(INIT_PAGE + offsetPage);
    }
    notifyPageChanged(INIT_PAGE + offsetPage);

  }
  ///[fromEnd]为true,[initIndex]为最后一页，需要从后往前填充内容
  Future<int> _loadChapter(int chapterIndex,int pageIndex,bool fromEnd) async{
    if(chapterIndex < 0 || chapterIndex >= chaptersList.length){
      return Future.value(-1);
    }
    //先占位加载中页面
    DisplayCache.getInstance().put(pageIndex, DisplayPage(DisplayPage.STATUS_LOADING, null,chapterIndex: chapterIndex,currPage: 1,viewPageIndex: pageIndex,fromEnd: fromEnd,));
    setState(() {
      if(chapterIndex == 0){
        firstPage = pageIndex;
      }
    });
    //获取正文
    String chapterContent = await contentHelper.getChapterContent(chaptersList[chapterIndex].id).catchError((e){
      DisplayCache.getInstance().put(pageIndex, DisplayPage(DisplayPage.STATUS_ERROR, null,chapterIndex: chapterIndex,currPage: 1,fromEnd: fromEnd,viewPageIndex: pageIndex,));
      setState(() {

      });
    });
    //失败?
    if(chapterContent == null || chapterContent.isEmpty){
      return Future.value(-1);
    }
    //成功开始分页,制造显示页面
    DisplayConfig config = DisplayConfig.getDefault();
    //内容中每个段落开头的空格
    var spaceForParagraph = ' ' * config.spaceParagraph;
    chapterContent = spaceForParagraph + chapterContent.replaceAll('\n', '\n$spaceForParagraph');

    //标题，正文
    final textStyle = TextStyle(
      color: Color(config.textColor),
      fontSize: config.textSize,
    );

    final textSpan = TextSpan(
      text: chapterContent,
      style: textStyle,
    );
    final titleStyle = TextStyle(
      color: Color(config.titleColor),
      fontSize: config.titleSize,
      fontWeight: FontWeight.bold,
    );
    final titleSpan = TextSpan(
      text: chaptersList[chapterIndex].name.trim(),
      style: titleStyle,
    );
    var textPageSize = Size(size.width- config.margin * 2, size.height - config.margin * 2);
    var pageBreaker = PageBreaker(textSpan, titleSpan, textPageSize);
    var pagesList = pageBreaker.splitPage();
    //分页完成填充数据
    for(var i = 0;i< pagesList.length;i++){
      DisplayCache.getInstance().put(pageIndex + (fromEnd?(i+1-pagesList.length):i), DisplayPage(DisplayPage.STATUS_SUCCESS, pagesList[i],chapterIndex: chapterIndex,currPage: i+1,maxPage: pagesList.length,));
    }

    setState(() {
      print('done!');
      if(fromEnd){
        firstPage = pageIndex - pagesList.length + 1;
      }
    });
    //通知该章节加载完成
    return Future.value(pagesList.length);

  }

  //滚动到了当前页码
  void notifyPageChanged(int index){
    print(index);
    var displayPage = DisplayCache.getInstance().get(index);
    if(displayPage == null) {
      return;
    }
    ChapterChangedEvent.getInstance().emit(chaptersList[displayPage.chapterIndex].name);
    //更新阅读记录
    if(displayPage.status == DisplayPage.STATUS_SUCCESS){
      DatabaseHelper().updateLastReadChapter(widget.bookId, chaptersList[displayPage.chapterIndex].name,displayPage.currPage);
    }

    //如果是章节第一页，加载前一章
    if(displayPage!=null && displayPage.currPage == 1){//第一页,加载上一章节
      var tempPage = DisplayCache.getInstance().get(index-1);
      if(tempPage!=null){
        //有缓存不加载
        return;
      }
      print('加载上一章节');
      _loadChapter(displayPage.chapterIndex-1, index-1, true);
    }
    //如果是章节最后一页，加载后一章
    if(displayPage!=null && displayPage.currPage == displayPage.maxPage){//最后一页,加载下一章节
      var tempPage = DisplayCache.getInstance().get(index+1);
      if(tempPage!=null){
        //有缓存不加载
        return;
      }
      print('加载下一章节');
      _loadChapter(displayPage.chapterIndex+1, index+1, false);
    }

  }

  void _nextChapter() async{
    var displayPage = DisplayCache.getInstance().get(_controller.page.ceil());
    if(displayPage.status == DisplayPage.STATUS_SUCCESS && displayPage.chapterIndex < chaptersList.length - 1){
      DisplayCache.getInstance().clear();
      firstPage = INIT_PAGE;
      await _loadChapter(displayPage.chapterIndex+1, INIT_PAGE, false);
      _controller.jumpToPage(INIT_PAGE);
      notifyPageChanged(INIT_PAGE);
    }
  }

  void _previousChapter() async{
    var displayPage = DisplayCache.getInstance().get(_controller.page.ceil());
    if(displayPage.status == DisplayPage.STATUS_SUCCESS && displayPage.chapterIndex > 0){
      DisplayCache.getInstance().clear();
      firstPage = INIT_PAGE;
      await _loadChapter(displayPage.chapterIndex - 1, INIT_PAGE, false);
      _controller.jumpToPage(INIT_PAGE);
      notifyPageChanged(INIT_PAGE);
    }
  }




}