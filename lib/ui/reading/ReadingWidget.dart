
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_content_helper.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/ui/reading/DisplayConfig.dart';
import 'package:yuedu_hd/ui/reading/DisplayPage.dart';
import 'package:yuedu_hd/ui/reading/DisplayCache.dart';
import 'package:yuedu_hd/ui/reading/PageBreaker.dart';

class ReadingWidget extends StatefulWidget{
  final int bookId;
  final String initChapterName;


  ReadingWidget(this.bookId, this.initChapterName);

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
  var displayPageList = LinkedHashMap<int,DisplayPage>();//页码对应显示页面

  var sizeKey = GlobalKey();
  var size = Size(-1, -1);

  PageController _controller;
  var firstPage = 0;

  @override
  void initState() {
    _controller = PageController(initialPage: INIT_PAGE);
    Future.delayed(Duration.zero,(){_setupData();});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: sizeKey,
      child: SizedBox(
        width: double.maxFinite,
        height: double.maxFinite,
        child: PageView.builder(itemBuilder: (ctx,index){
          if(index < firstPage){
            return _buildErrorIndex();
          }
          return DisplayCache.getInstance().get(index);
        },controller: _controller,
          itemCount: MAX_PAGE,onPageChanged: (i){
            print(i);
            //todo 10张页面判断加载上下章节。
          },
        ),
      ),
    );
  }

  Widget _buildErrorIndex(){
    return Center(
      child: Text('没有了啦'),
    );
  }


  void _setupData() async{
    size = Size.copy(sizeKey.currentContext.size);
    print(size);
    await _fetchChapters();
  }

  void _fetchChapters() async{
    //只从数据库获取目录
    var chapters = await tocHelper.getChapterListOnlyDB(widget.bookId);
    chaptersList.clear();
    chaptersList.addAll(chapters);
    _onChaptersLoad();
  }

  ///目录加载完成
  void _onChaptersLoad(){
    if(chaptersList.isEmpty){
      return;
    }
    //当前阅读的章节，找到章节id
    for(var i =0;i<chaptersList.length;i++){
      var value = chaptersList[i];
      if(value.name == widget.initChapterName){
        initChapterId = value.id;
        currChapterIndex =i;
        break;
      }
    }

    if(initChapterId == -1){
      initChapterId = chaptersList[0].id;
      currChapterIndex = 0;
    }
    //获取章节内容
    _loadChapter(currChapterIndex,INIT_PAGE,false);
    //本章，上下章节


  }
  ///[fromEnd]为true,[initIndex]为最后一页，需要从后往前填充内容
  void _loadChapter(int chapterIndex,int pageIndex,bool fromEnd) async{
    //先占位加载中页面
    DisplayCache.getInstance().put(pageIndex, DisplayPage(DisplayPage.STATUS_LOADING, null));
    setState(() {
      firstPage = pageIndex;
    });
    //获取正文
    String chapterContent = await contentHelper.getChapterContent(chaptersList[chapterIndex].id);
    print(chapterContent);
    //失败?

    //成功开始分页,制造显示页面
    DisplayConfig config = DisplayConfig.getDefault();
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
      text: chaptersList[chapterIndex].name,
      style: titleStyle,
    );
    var pageBreaker = PageBreaker(textSpan, titleSpan, size);
    var pagesList = pageBreaker.splitPage();
    //分页完成填充数据
    for(var i = 0;i< pagesList.length;i++){
      DisplayCache.getInstance().put(pageIndex + i, DisplayPage(DisplayPage.STATUS_SUCCESS, pagesList[i]));
    }
    setState(() {
      print('done!');
    });
    //通知该章节加载完成


  }




}