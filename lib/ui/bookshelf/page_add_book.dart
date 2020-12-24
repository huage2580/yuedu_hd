import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/book_search_helper.dart';
import 'package:yuedu_hd/ui/bookshelf/widget_book_detail.dart';
import 'package:yuedu_hd/ui/widget/image_async.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

class PageAddBook extends StatefulWidget{
  @override
  _PageAddBookState createState() => _PageAddBookState();
}

class _PageAddBookState extends State<PageAddBook>{

  TextEditingController _searchController = TextEditingController();
  var _searchHelper = BookSearchHelper.getInstance();
  bool _canStop = false;

  var _searchResultList = List<BookInfoBean>();

  var _selectBookId = -1;//5 for test,default -1
  var isLandscape = false;

  var _canPostUpdateUI = true;

  @override
  void initState() {
    //更新UI的间隔至少要两秒
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
    //终止搜索
    _searchHelper.cancelSearch('test');
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: OrientationBuilder( builder: (context,orientation){
        if(isLandscape){
          return _buildPageLandscape(theme, context);
        }else{
          return _buildPagePortrait(theme, context);
        }
      },),
    );
  }

  Row _buildPageLandscape(ThemeData theme, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Row(
                      children: [
                        IconButton(icon: Icon(CupertinoIcons.back,color: theme.primaryColor,), onPressed: (){
                          Navigator.of(context).pop();
                        }),
                        Expanded(child: _buildSearch(theme)),
                        HSpace(8),
                      ],
                    ),
                  ),
                  Visibility(visible: _canStop,child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColorLight),)),
                  Expanded(child: _buildSearchList(context)),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Visibility(
                  visible: _canStop,
                  child: FloatingActionButton(onPressed: (){
                    _searchHelper.cancelSearch('test');
                    BotToast.showText(text:"请等待线程结束...");
                  },child: Icon(Icons.stop),backgroundColor: theme.primaryColor,foregroundColor: theme.canvasColor,),
                ),
              ),
            ],
          ),
        ),
        VerticalDivider(width: 0.5,thickness: 0.5,),
        Expanded(child: BookDetailWidget(_selectBookId)),
      ],
    );
  }

  Widget _buildPagePortrait(ThemeData theme, BuildContext context) {
    return Stack(
      children: [
        Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      IconButton(icon: Icon(CupertinoIcons.back,color: theme.primaryColor,), onPressed: (){
                        Navigator.of(context).pop();
                      }),
                      Expanded(child: _buildSearch(theme)),
                      HSpace(8),
                    ],
                  ),
                ),
                Visibility(visible: _canStop,child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColorLight),)),
                Expanded(child: _buildSearchList(context)),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Visibility(
                visible: _canStop,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: FloatingActionButton(onPressed: (){
                    _searchHelper.cancelSearch('test');
                    BotToast.showText(text:"请等待线程结束...");
                  },child: Icon(Icons.stop),backgroundColor: theme.primaryColor,foregroundColor: theme.canvasColor,),
                ),
              ),
            ),
          ],
        ),
        Visibility(visible: _selectBookId !=-1,child: Container(color: theme.backgroundColor,child: BookDetailWidget(_selectBookId,backClick: (){
          _selectBookId = -1;
          setState(() {

          });
        },))),
      ],
    );
  }


  Container _buildSearch(ThemeData theme) {
    return Container(
      height: 40,
      width: double.maxFinite,
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: theme.canvasColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (s){
                _searchKey();
              },
              onChanged: (s){
                setState(() {

                });
              },
              autofocus: false,
              maxLines: 1,
              decoration: InputDecoration(
                hintText: '输入书名或作者 搜索书籍',
                prefixIconConstraints:
                BoxConstraints(minWidth: 24, maxHeight: 24),
                prefixIcon: Icon(
                  Icons.search_outlined,
                  color: theme.hintColor,
                  size: 24,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Visibility(
            visible: _searchController.text.isNotEmpty,
            child: GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {

                });
              },
              child: Icon(
                CupertinoIcons.clear_circled_solid,
                color: theme.hintColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchList(BuildContext context){
    return Container(
      child: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: CupertinoScrollbar(
          child: ListView.separated(itemBuilder: (ctx,index){
            return _buildItem(ctx,_searchResultList[index]);
          }, separatorBuilder: (c,i)=>Divider(height: 0.5,thickness: 0.5,), itemCount: min(30, _searchResultList.length)),
        ),
      ),
    );
  }


  Widget _buildItem(BuildContext ctx, BookInfoBean infoBean) {
    var theme = Theme.of(ctx);
    return GestureDetector(
      onTap: (){
        _selectBookId = infoBean.id;
        //终止搜索
        _searchHelper.cancelSearch('test');
        setState(() {

        });
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          // color: theme.cardColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 100,width: 80,child: FadeInImageWithoutAuth.network(infoBean.coverUrl,
              // loadingBuilder: (BuildContext context, Widget child,
              //     ImageChunkEvent loadingProgress) {
              //   if (loadingProgress == null) return child;
              //   return Container(
              //     height: 120,
              //     width: 100,
              //     color: Colors.grey,
              //     child: Center(child: Text('loading'),),
              //   );
              // },
              // errorBuilder: (BuildContext context, Object exception,
              //     StackTrace stackTrace) {
              //   return Container(
              //     height: 120,
              //     width: 100,
              //     color: Colors.grey,
              //   );
              // },
            )),
            HSpace(8),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(infoBean.name,style: TextStyle(fontWeight: FontWeight.bold,fontSize: theme.textTheme.subtitle1.fontSize),),
                Text(infoBean.author),
                Text('${infoBean.sourceBean.bookSourceName}等${infoBean.sourceCount}个书源'),
                Text(infoBean.intro??'没有简介内容',maxLines: 3,overflow: TextOverflow.ellipsis,softWrap: true,)
              ],
            )),
          ],
        ),
      ),
    );
  }

  dynamic _searchKey() async{
    _searchResultList.clear();
    setState(() {
      _selectBookId = -1;
      _canStop = true;
    });
    var result = await _searchHelper.searchBookFromEnabledSource(_searchController.text, 'test',onBookSearch: (book) async{
      var temp = book;
      if(_searchResultList.contains(book)){
        var index = _searchResultList.indexOf(book);
        temp = _searchResultList[index];
        if(temp.intro==null || temp.intro.isEmpty){//填充简介
          temp.intro = book.intro;
        }
      }else{
        if(_searchResultList.length < 200){//不重复结果超过200本书，不继续显示
          _searchResultList.add(book);
        }
      }
      temp.sourceCount += 1;
    },updateList: (){
      //按书源数量排序
      _wantUpdateList();
    });
    if(_searchResultList.isEmpty){
      BotToast.showText(text: '搜索失败，请确认添加并启用书源,检查网络和搜索关键字');
    }
    setState(() {
      _canStop = false;
    });
  }

  //控制UI更新的间隔，IOS频繁更新UI特别卡顿
  void _wantUpdateList(){
    if(!_canPostUpdateUI){
      return;
    }
    _canPostUpdateUI = false;
    _searchResultList.sort((a,b){return b.sourceCount.compareTo(a.sourceCount);});
    Future.delayed(Duration(milliseconds: 1000),(){
      setState(() {

      });
    }).whenComplete((){_canPostUpdateUI = true;}
    );
  }
}