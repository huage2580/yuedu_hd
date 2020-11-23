import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/book_search_helper.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

class PageAddBook extends StatefulWidget{
  @override
  _PageAddBookState createState() => _PageAddBookState();
}

class _PageAddBookState extends State<PageAddBook>{
  TextEditingController _searchController = TextEditingController();
  var _searchHelper = BookSearchHelper.getInstance();


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
                    )
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(onPressed: (){
                    _searchHelper.cancelSearch('test');
                  },child: Icon(Icons.stop),backgroundColor: theme.primaryColor,foregroundColor: theme.canvasColor,),
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
              onEditingComplete: (){
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

  dynamic _searchKey() async{
    await _searchHelper.searchBookFromEnabledSource(_searchController.text, 'test',onBookSearch: (book){
      print(book);
    });
  }

}