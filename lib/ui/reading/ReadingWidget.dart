
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/ui/reading/DisplayPage.dart';

class ReadingWidget extends StatefulWidget{
  final int bookId;
  final String initChapterName;


  ReadingWidget(this.bookId, this.initChapterName);

  @override
  _ReadingWidgetState createState() => _ReadingWidgetState();
}

class _ReadingWidgetState extends State<ReadingWidget> {
  var curChapterId;
  var displayPageList = LinkedHashMap<int,DisplayPage>();//页码对应显示页面

  PageController _controller;
  static const MAX_PAGE = 1999999999;
  static final INIT_PAGE = (MAX_PAGE/2).ceil();

  @override
  void initState() {
    _controller = PageController(initialPage: INIT_PAGE);
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


  void _fetchChapters(){
    //只从数据库获取目录
    //当前阅读的章节，找到章节id
    //获取章节内容
    //填充章节视图到缓存
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