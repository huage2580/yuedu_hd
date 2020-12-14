import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/book_source/widget_select_source.dart';
import 'package:yuedu_hd/ui/bookshelf/widget_chapters.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

///书籍详情
class BookDetailWidget extends StatefulWidget {
  final int bookId;
  final Function backClick;

  BookDetailWidget(this.bookId, {this.backClick}) : super(key: ValueKey(bookId));

  @override
  State<StatefulWidget> createState() {
    return BookDetailState();
  }
}

class BookDetailState extends State<BookDetailWidget> {
  BookInfoBean bookDetail;
  String firstChapter='获取目录中...';

  @override
  void initState() {
    super.initState();
    _fetchDetail(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return bookDetail == null ? _buildEmpty() : _buildDetail(context);
  }

  Widget _buildEmpty() {
    return Container(
      child: Center(child: Text(widget.bookId>0?'加载中...':'要不你先搜索下\n(*^_^*)',textAlign: TextAlign.center,)),
    );
  }

  Widget _buildDetail(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    var theme = Theme.of(context);
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        height: 80,
                        width: double.maxFinite,
                        child: CustomPaint(
                          painter: _ArcPainter(context),
                        ),
                      )),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                        height: 120,
                        width: 96,
                        child: Image.network(bookDetail.coverUrl,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 120,
                              width: 100,
                              color: Colors.grey,
                              child: Center(child: Text('loading'),),
                            );
                          },
                          errorBuilder: (BuildContext context, Object exception,
                              StackTrace stackTrace) {
                            return Container(
                              height: 120,
                              width: 100,
                              color: Colors.grey,
                            );
                          },
                        )),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Container(
              width: double.maxFinite,
              color: theme.cardColor,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    bookDetail.name,
                    style: theme.textTheme.headline5,
                  ),
                  VSpace(8),
                  _buildTags(context),
                  VSpace(16),
                  Expanded(child: _buildInfo(context)),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                  ),
                  Container(
                    height: 50,
                    child: Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              _fetchDetail(widget.bookId);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Icon(Icons.sync),
                            )),
                        VerticalDivider(width: 0.5,thickness: 1,),
                        Expanded(
                            child: SizedBox(
                                height: 50,
                                child: FlatButton(
                                    onPressed: () async{
                                      await DatabaseHelper().addToBookShelf(widget.bookId);
                                      setState(() {
                                        bookDetail.inbookShelf = 1;
                                      });
                                    },
                                    child: Text(bookDetail.inbookShelf == 0?'加入书架':'已在书架'),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap))),
                        Expanded(
                            child: SizedBox(
                                height: 50,
                                child: FlatButton(
                                    onPressed: () {
                                      YDRouter.mainRouter.currentState.pushNamed(YDRouter.READING_PAGE,arguments: {'bookId':bookDetail.id});
                                    },
                                    child: Text('开始阅读'),
                                    color: theme.primaryColor,
                                    textColor: theme.canvasColor,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap))),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        if(!isLandscape)
          Container(
            padding: EdgeInsets.all(8),
            child: IconButton(icon: Icon(CupertinoIcons.back,color: theme.primaryColor,), onPressed: (){
              widget.backClick();
            }),
          ),
      ],
    );
  }

  Widget _buildTags(BuildContext context) {
    var theme = Theme.of(context);
    var tags = bookDetail.kind.split('|');
    return Wrap(
      spacing: 8,
      children: [
        for (var tag in tags)
          Container(
            padding: EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(2))),
            child: Text(
              tag,
              style: TextStyle(color: theme.accentColor, fontSize: 13),
            ),
          )
      ],
    );
  }

  Widget _buildInfo(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(CupertinoIcons.person_circle,),
                  HSpace(8),
                  Text('作者: ${bookDetail.author}',style: theme.textTheme.headline6,maxLines: 1,overflow: TextOverflow.ellipsis,),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(Icons.explore_outlined),
                  HSpace(8),
                  Expanded(child: Text('来源: ${bookDetail.sourceBean.bookSourceName}',style: theme.textTheme.headline6,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                  SizedBox(height: 26,width: 60,child: FlatButton(onPressed: (){
                    _showSelectSource(context);
                  }, child: Text('换源'), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,color: theme.primaryColor,textColor: theme.canvasColor,)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(CupertinoIcons.bolt_circle),
                  HSpace(8),
                  Expanded(child: Text('最新章节: ${bookDetail.lastChapter}',style: theme.textTheme.subtitle1,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(4),
              child: Row(
                children: [
                  Icon(CupertinoIcons.book_circle),
                  HSpace(8),
                  Expanded(child: Text('目录: $firstChapter',style: theme.textTheme.subtitle1,maxLines: 1,overflow: TextOverflow.ellipsis,)),
                  SizedBox(height: 26,child: FlatButton(onPressed: (){
                    _showChapters(context);
                  }, child: Text('查看目录'), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,color: theme.primaryColor,textColor: theme.canvasColor,)),

                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.all(4),
            //   child: Row(
            //     children: [
            //       Icon(CupertinoIcons.folder_circle),
            //       HSpace(8),
            //       Expanded(child: Text('分组: ${bookDetail.groupId}',style: theme.textTheme.subtitle1,maxLines: 1,overflow: TextOverflow.ellipsis,)),
            //       SizedBox(height: 26,child: FlatButton(onPressed: (){
            //         BotToast.showText(text: '不支持分组!');
            //       }, child: Text('设置分组'), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,color: theme.primaryColor,textColor: theme.canvasColor,)),
            //     ],
            //   ),
            // ),
            VSpace(16),
            Text(bookDetail.intro??'简介为空'),
          ],
        ),
      ),
    );
  }

  void _fetchDetail(int bookId) async {
    if (bookId <= 0) {
      return;
    }
    bookDetail = await DatabaseHelper().queryBookInfoFromBookIdCombSourceId(bookId,-1);
    setState(() {
      firstChapter = '获取中...';
    });
    var chapterList = await BookTocHelper.getInstance()
        .updateChapterList(bookId, -1, notUpdateDB: false).catchError((e) => null);
    // for (var value in chapterList) {
    //   print(value.toString());
    // }
    if(chapterList==null || chapterList.isEmpty){
      firstChapter = '目录空,请重试或换源';
    }else{
      firstChapter = chapterList[0].name;
      bookDetail.lastChapter = chapterList.last.name;
    }
    setState(() {

    });
  }

  void _showSelectSource(context) async{
    var result = await showDialog(context:context,child: Dialog(child: WidgetSelectSource(widget.bookId),));
    if(result != null){
      _fetchDetail(widget.bookId);
    }
  }

  void _showChapters(BuildContext context)async{
    var result = await showDialog(context:context,child: Dialog(child: ChaptersWidget(widget.bookId,(bean){

    }),));
    if(result!=null){
      YDRouter.mainRouter.currentState.pushNamed(YDRouter.READING_PAGE,arguments: {'bookId':widget.bookId,'initChapterName':result});
    }
  }

}


class _ArcPainter extends CustomPainter {
  Paint _mPaint;

  @override
  void paint(Canvas canvas, Size size) {
    var rectDraw = Rect.fromLTWH(0, 0, size.width, size.height);
    var rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.clipRect(rectDraw);
    canvas.drawOval(rect, _mPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  _ArcPainter(BuildContext context) {
    _mPaint = Paint();
    _mPaint.color = Theme.of(context).cardColor;
  }
}
