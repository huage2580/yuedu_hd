

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:yuedu_hd/db/BookShelfBean.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/widget/space.dart';
import 'package:yuedu_hd/ui/style/ycolors.dart';

class PageBookShelf extends StatefulWidget {
  @override
  _PageBookShelfState createState() => _PageBookShelfState();
}

class _PageBookShelfState extends State<PageBookShelf>
    with SingleTickerProviderStateMixin {
  var _tabController;

  var _bookList = List<BookShelfBean>();
  var _tocHelper = BookTocHelper.getInstance();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _fetchBookShelf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    tabs: [
                      Tab(
                        text: '全部',
                      ),
                      Tab(
                        text: '分组一',
                      ),
                      Tab(
                        text: '分组二',
                      ),
                    ],
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    labelColor: theme.textTheme.headline6.color,
                  ),
                ),
                PopupMenuButton(
                  tooltip: '排序方式',
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem(
                        child: Text('默认排序'),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: Text('添加顺序'),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text('最后更新'),
                        value: 2,
                      ),
                    ];
                  },
                  child: IgnorePointer(
                    child: TextButton.icon(
                        onPressed: (){},
                        icon: Icon(Icons.sort_outlined),
                        label: Text('默认排序'),),
                  ),
                ),
              ],
            ),
            VSpace(4),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: YColors.border_color, width: 5),
                color: theme.cardColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  Container(margin: EdgeInsets.all(8),child: _buildList(context)),
                  Container(
                    margin: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: (){
                          Navigator.of(context).pushNamed(YDRouter.BOOK_ADD)
                              .then((value) => _fetchBookShelf());
                        },
                        child: Icon(Icons.add),
                        backgroundColor: theme.primaryColorDark,
                        foregroundColor: theme.canvasColor,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildList(context) {
    return RefreshIndicator(
      color: YColors.primary,
      onRefresh: ()async{
        return await _updateToc();
      },
      child: WaterfallFlow.builder(gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2
      ),itemBuilder: (ctx,index)=>_buildBookItem(ctx, _bookList[index]),itemCount: _bookList.length,),
      // child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //   crossAxisCount: 2,childAspectRatio: 2.4,crossAxisSpacing: 2,mainAxisSpacing: 8,
      // ), itemBuilder: (ctx,index)=>_buildBookItem(ctx, _bookList[index]),itemCount: _bookList.length,),
    );
  }


  Widget _buildBookItem(BuildContext context,BookShelfBean bean){
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: (){
        YDRouter.mainRouter.currentState.pushNamed(YDRouter.READING_PAGE,arguments: {'bookId':bean.bookId,'chapterId':-1});
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            SizedBox(height: 120,width: 100,child: Image.network(bean.coverUrl)),
            HSpace(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(bean.bookName,style: theme.textTheme.headline6,overflow:TextOverflow.ellipsis,)),
                      Container(
                        padding: EdgeInsets.only(left: 8,right: 8,top: 4,bottom: 4),
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),color: theme.primaryColorLight),
                        child: Text('${bean.notReadChapterCount}'),
                      ),
                    ],
                  ),
                  VSpace(8),
                  Row(
                    children: [
                      Icon(CupertinoIcons.person_circle,size: 18,color: theme.disabledColor),
                      HSpace(4),
                      Text(bean.bookAuthor,style: theme.textTheme.headline6,),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(CupertinoIcons.bolt_circle,size: 18,color: theme.disabledColor),
                      HSpace(4),
                      Expanded(child: Text(bean.lastReadChapter??'未阅读',overflow: TextOverflow.ellipsis,style: theme.textTheme.headline6),),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(CupertinoIcons.book_circle,size: 18,color: theme.disabledColor,),
                      HSpace(4),
                      Expanded(child: Text(bean.lastChapter??'目录为空',overflow: TextOverflow.ellipsis,style: theme.textTheme.headline6)),
                    ],
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }


  dynamic _fetchBookShelf() async{
    var temp = await DatabaseHelper().queryBookInBookShelf();
    _bookList.clear();
    _bookList.addAll(temp);
    setState(() {

    });
    return Future.value(0);
  }

  dynamic _updateToc() async{
    await _fetchBookShelf();
    var futureList = List<Future>();
    for (var book in _bookList) {
      futureList.add(_tocHelper.updateChapterList(book.bookId, book.sourceId));
    }
    await Future.wait(futureList);
    await _fetchBookShelf();
    return Future.value(0);
  }
}
