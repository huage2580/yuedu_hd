
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookSourceCombBean.dart';
import 'package:yuedu_hd/db/CountLock.dart';
import 'package:yuedu_hd/db/book_search_helper.dart';
import 'package:yuedu_hd/db/book_toc_helper.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';

class WidgetSelectSource extends StatefulWidget{
  final int bookId;

  WidgetSelectSource(this.bookId) : super(key: ValueKey(bookId));

  @override
  _WidgetSelectSourceState createState() => _WidgetSelectSourceState();
}

class _WidgetSelectSourceState extends State<WidgetSelectSource> {
  var dbHelper = DatabaseHelper();

  List<BookSourceCombBean> sourceList = [];
  List<String> _cancelTokenList = [];

  var _searching = false;
  var _canPostUpdateUI = true;
  var _countLock = CountLock(4);

  @override
  void initState() {
    _fetchSourceList();
    super.initState();
  }


  @override
  void dispose() {
    BookSearchHelper.getInstance().cancelSearch('source');
    _cancelTokenList.forEach((element) {
      BookTocHelper.getInstance().cancel(element);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Material(
      child: Container(
        height: 400,
        width: 300,
        color: theme.cardColor,
        child:  Column(
          children: [
            Row(
              children: [
                FlatButton.icon(icon: Icon(_searching?Icons.stop:CupertinoIcons.refresh,size: 18,),label: Text(_searching?'终止搜索书源':'重新搜索书源',style: theme.textTheme.bodyText1,),onPressed: (){
                  _fetchMoreSource();
                },),
                Spacer(),
                IconButton(icon: Icon(Icons.sync,size: 18,), onPressed: (){
                  sourceList.clear();
                  _fetchSourceList();
                })
              ],
            ),
            Divider(height: 1,thickness: 1,),
            Visibility(visible: _searching,child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColorLight),)),
            Expanded(
              child: CupertinoScrollbar(
                child: ListView.separated(shrinkWrap: true,itemBuilder: (ctx,index){
                  return _buildItem(ctx, sourceList[index]);
                },separatorBuilder: (c,i)=>Divider(height: 0.5,thickness: 0.5,),itemCount: sourceList.length,),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext ctx,BookSourceCombBean bean){
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async{
        await dbHelper.switchUsedSource(bean.bookid, bean.sourceid);
        Navigator.of(context).pop(bean.id);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${bean.sourceBean.bookSourceName}',maxLines: 2,overflow: TextOverflow.ellipsis,),
                  Text('${bean.lastChapterName?? '正在获取目录~'}')
                ],
              ),
            ),
            if(bean.used == 1)
              Icon(Icons.check,size: 20,)
          ],
        ),
      ),
    );
  }

  void _fetchSourceList() async{

    var sources = await dbHelper.queryAllEnabledSource(widget.bookId);
    sourceList.addAll(sources);
    setState(() {
      //先更新列表，然后获取目录
    });
    for (var source in sourceList) {
      await _countLock.request();
      updateChapter(source);
    }
  }

  void _fetchMoreSource() async{
    setState(() {
      _searching = true;
    });
    var book = await DatabaseHelper().queryBookById(widget.bookId);
    await BookSearchHelper.getInstance().searchBookFromEnabledSource(book.name!, 'source',author: book.author,exactSearch: true,onBookSearch: (b){
      var index =sourceList.indexWhere((element) => element.sourceid == b.source_id);
      if(index == -1){
        //添加书源
        var t = BookSourceCombBean();
        t.sourceid = b.source_id;
        t.bookid = b.id;
        t.sourceBean = b.sourceBean!;
        sourceList.add(t);
        updateChapter(t);
      }
    });
    setState(() {
      _searching = false;
    });
  }

  dynamic updateChapter(BookSourceCombBean source) async{
    if(!this.mounted){return;}
    await BookTocHelper.getInstance().updateChapterList(source.bookid, source.sourceid,notUpdateDB: true,onlyLast: true,onCancelToken: (token){
      _cancelTokenList.add(token);
    }).then((chapters){
      source.lastChapterName = chapters.last.name!;
      _countLock.release();
      _wantUpdateList();
    }).catchError((e){
      _countLock.release();
      source.lastChapterName = '[X]目录解析异常';
      _wantUpdateList();
    });
  }

  //控制UI更新的间隔，IOS频繁更新UI特别卡顿
  void _wantUpdateList(){
    if(!this.mounted){
      return;
    }
    if(!_canPostUpdateUI){
      return;
    }
    _canPostUpdateUI = false;
    Future.delayed(Duration(milliseconds: 500),(){
      setState(() {

      });
    }).whenComplete((){_canPostUpdateUI = true;}
    );
  }
}