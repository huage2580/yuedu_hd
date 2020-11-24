import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookInfoBean.dart';
import 'package:yuedu_hd/db/book_search_helper.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Row(
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
                          HSpace(16),
                        ],
                      ),
                    ),
                    Expanded(child: _buildSearchList(context)),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Visibility(
                    visible: _canStop,
                    child: FloatingActionButton(onPressed: (){
                      _searchHelper.cancelSearch('test');
                    },child: Icon(Icons.stop),backgroundColor: theme.primaryColor,foregroundColor: theme.canvasColor,),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(),
          Expanded(child: Container(color: theme.primaryColor,child: Text('data'),)),
        ],
      ),
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
                hintText: '根据标题 搜索书源',
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
      child: CupertinoScrollbar(
        child: ListView.separated(itemBuilder: (ctx,index){
          return _buildItem(ctx,_searchResultList[index]);
        }, separatorBuilder: (c,i)=>Divider(height: 0.5,thickness: 0.5,), itemCount: _searchResultList.length),
      ),
    );
  }


  Widget _buildItem(BuildContext ctx, BookInfoBean infoBean) {
    var theme = Theme.of(ctx);
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        // color: theme.cardColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 90,width: 60,child: Image.network(infoBean.coverUrl)),
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
    );
  }

  dynamic _searchKey() async{
    _searchResultList.clear();
    setState(() {
      _canStop = true;
    });
    var result = await _searchHelper.searchBookFromEnabledSource(_searchController.text, 'test',onBookSearch: (book){
      var temp = book;
      if(_searchResultList.contains(book)){
        var index = _searchResultList.indexOf(book);
        temp = _searchResultList[index];
        if(temp.intro==null || temp.intro.isEmpty){//填充简介
          temp.intro = book.intro;
        }
      }else{
        _searchResultList.add(book);
      }
      temp.sourceCount += 1;
      //按书源数量排序
      _searchResultList.sort((a,b){return b.sourceCount.compareTo(a.sourceCount);});
      setState(() {

      });
    });
    setState(() {
      _canStop = false;
    });
  }
}