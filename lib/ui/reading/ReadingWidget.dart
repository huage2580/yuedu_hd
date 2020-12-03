
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/db/bookChapterBean.dart';
import 'package:yuedu_hd/db/book_content_helper.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/ui/reading/DisplayPage.dart';

class ReadingWidget extends StatefulWidget{
  final int bookId;
  final String initChapterName;


  ReadingWidget(this.bookId, this.initChapterName);

  @override
  _ReadingWidgetState createState() => _ReadingWidgetState();
}

class _ReadingWidgetState extends State<ReadingWidget> {
  var tocHelper = BookTocHelper.getInstance();
  var contentHelper = BookContentHelper.getInstance();
  var chaptersList = List<BookChapterBean>();
  var currChapterIndex = 0;
  var initChapterId = -1;
  var displayPageList = LinkedHashMap<int,DisplayPage>();//页码对应显示页面

  PageController _controller;
  static const MAX_PAGE = 1999999999;
  static final INIT_PAGE = (MAX_PAGE/2).ceil();

  @override
  void initState() {
    _controller = PageController(initialPage: INIT_PAGE);
    _fetchChapters();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView.builder(itemBuilder: (ctx,index){
        return Center(
          child: Text("测试$index"),
        );
      },controller: _controller,
        itemCount: MAX_PAGE,
      ),
    );
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
    _loadChapter(currChapterIndex);


  }

  void _loadChapter(int chapterIndex) async{
    String chapterContent = await contentHelper.getChapterContent(chaptersList[chapterIndex].id);
    print(chapterContent);
  }

  ///[fromEnd]为true,[initIndex]为最后一页，需要从后往前填充内容
  void _fillChapter(int chapterId,int initIndex,bool fromEnd){
    //先占位加载中页面
    //数据库获取正文
    //失败?
    //成功开始分页
    //分页完成填充数据
    //通知该章节加载完成

  }


}