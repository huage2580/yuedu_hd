import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waterfall_flow/waterfall_flow.dart';
import 'package:yuedu_hd/db/BookShelfBean.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/widget/WheelScroll4Desktop.dart';
import 'package:yuedu_hd/ui/widget/space.dart';
import 'package:yuedu_hd/ui/style/ycolors.dart';

class PageBookShelf extends StatefulWidget {
  @override
  _PageBookShelfState createState() => _PageBookShelfState();
}

class _PageBookShelfState extends State<PageBookShelf>
    with SingleTickerProviderStateMixin {
  var _tabController;

  List<BookShelfBean> _bookList =[];
  var _tocHelper = BookTocHelper.getInstance();

  var currSortType = 1; //0添加顺序，1上次阅读时间

  var _scrollController = ScrollController();

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    _fetchBookShelf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(isPortrait ? 8 : 20),
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
                      // Tab(
                      //   text: '分组一',
                      // ),
                      // Tab(
                      //   text: '分组二',
                      // ),
                    ],
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    labelColor: theme.textTheme.headline6!.color,
                  ),
                ),
                PopupMenuButton(
                  tooltip: '排序方式',
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem(
                        child: Text('添加顺序'),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: Text('上次阅读'),
                        value: 1,
                      ),
                    ];
                  },
                  onSelected: (i) {
                    currSortType = i as int;
                    _fetchBookShelf();
                  },
                  child: IgnorePointer(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.sort_outlined),
                      label: Text(currSortType == 0 ? '添加顺序' : '上次阅读'),
                    ),
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
                  Container(
                      margin: EdgeInsets.all(8),
                      child: _buildList(context, isPortrait)),
                  Container(
                    margin: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(YDRouter.BOOK_ADD)
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

  Widget _buildList(context, bool isPortrait) {

    if (_bookList.isEmpty) {
      return Center(
        child: Text('你的书架空空如也~\n\n\n😀\n\n请先添加书源:\n下方【书源】->点击【添加书源】\n然后点击右下角[+]按钮开始搜索书籍',textAlign: TextAlign.center,),
      );
    }
    return RefreshIndicator(
      color: YColors.primary,
      onRefresh: () async {
        return await _updateToc();
      },
      child: WheelScroll4Desktop(
        scrollController: _scrollController,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {
              PointerDeviceKind.touch,PointerDeviceKind.mouse
            }),
            child: WaterfallFlow.builder(
              controller: _scrollController,
              gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isPortrait ? 1 : 2),
              itemBuilder: (ctx, index) => _buildBookItem(ctx, _bookList[index]),
              itemCount: _bookList.length,
            ),
          ),
        ),
      ),
      // child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //   crossAxisCount: 2,childAspectRatio: 2.4,crossAxisSpacing: 2,mainAxisSpacing: 8,
      // ), itemBuilder: (ctx,index)=>_buildBookItem(ctx, _bookList[index]),itemCount: _bookList.length,),
    );
  }

  Widget _buildBookItem(BuildContext context, BookShelfBean bean) {
    var theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        DatabaseHelper().updateBookReadTime(bean.bookId);
        YDRouter.mainRouter.currentState?.pushNamed(YDRouter.READING_PAGE,
            arguments: {'bookId': bean.bookId}).then((value) {
          _fetchBookShelf();
        }); //更新阅读记录
      },
      onLongPress: () {
        _showDelete(context, bean);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Container(
              color: Colors.grey,
              child: SizedBox(
                  height: 120,
                  width: 100,
                  child:
                  ExtendedImage.network(
                    bean.coverUrl,
                    width: 80,
                    height: 100,
                    fit: BoxFit.cover,
                    cache: true,
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    //cancelToken: cancellationToken,
                  ),

                  // Image.network(
                  //   bean.coverUrl,
                  //   fit: BoxFit.cover,
                  //   loadingBuilder: (BuildContext context, Widget child,
                  //       ImageChunkEvent? loadingProgress) {
                  //     if (loadingProgress == null) return child;
                  //     return Container(
                  //       height: 120,
                  //       width: 100,
                  //       color: Colors.grey,
                  //       child: Center(child: Text('loading'),),
                  //     );
                  //   },
                  //   errorBuilder: (BuildContext context, Object exception,
                  //       StackTrace? stackTrace) {
                  //     return Container(
                  //       height: 120,
                  //       width: 100,
                  //       color: Colors.grey,
                  //     );
                  //   },
                  // )
              ),
            ),
            HSpace(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        bean.bookName,
                        style: theme.textTheme.headline6,
                        overflow: TextOverflow.ellipsis,
                      )),
                      Container(
                        padding: EdgeInsets.only(
                            left: 8, right: 8, top: 4, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: theme.primaryColorLight),
                        child: Text('${bean.notReadChapterCount}'),
                      ),
                    ],
                  ),
                  VSpace(8),
                  Row(
                    children: [
                      Icon(CupertinoIcons.person_circle,
                          size: 18, color: theme.disabledColor),
                      HSpace(4),
                      Text(
                        bean.bookAuthor,
                        style: theme.textTheme.subtitle1,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(CupertinoIcons.bolt_circle,
                          size: 18, color: theme.disabledColor),
                      HSpace(4),
                      Expanded(
                        child: Text(bean.lastReadChapter ?? '未阅读',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.subtitle1),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.book_circle,
                        size: 18,
                        color: theme.disabledColor,
                      ),
                      HSpace(4),
                      Expanded(
                          child: Text(bean.lastChapter ?? '目录为空',
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.subtitle1)),
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

  dynamic _fetchBookShelf() async {
    await DatabaseHelper().loadConfig();
    var temp = await DatabaseHelper().queryBookInBookShelf(currSortType);
    _bookList.clear();
    _bookList.addAll(temp);
    setState(() {});
    return Future.value(0);
  }

  dynamic _updateToc() async {
    await _fetchBookShelf();
    List<Future> futureList = [];
    for (var book in _bookList) {
      futureList.add(_tocHelper
          .updateChapterList(book.bookId, book.sourceId)
          .then((value) => BotToast.showText(text: '${book.bookName} 更新成功'))
          .catchError((e) {
        BotToast.showText(text: '${book.bookName} 更新失败\n$e');
      }));
    }
    await Future.wait(futureList);
    await _fetchBookShelf();
    return Future.value(0);
  }

  void _showDelete(BuildContext context, BookShelfBean bean) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Row(
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text('确定删除 ${bean.bookName} ?')
        ],
      ),
      action: SnackBarAction(
        textColor: Colors.red,
        label: '删除',
        onPressed: () async {
          await DatabaseHelper().removeBookshelfById(bean.bookId);
          _fetchBookShelf();
        },
      ),
    ));
  }
}
