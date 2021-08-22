import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/db/source_verify_helper.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';

import '../widget/space.dart';

///书源列表
class PageSourceList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _StateSourceList();
  }
}

class _StateSourceList extends State<PageSourceList> {
  List<BookSourceBean> bookSourceList = [];
  bool showLoading = true;
  int _selectCount = 0;
  TextEditingController _searchController = TextEditingController();
  var isLandscape = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1))
        .then((value) => _fetchListAndUpdate(null));
  }

  @override
  Widget build(BuildContext context) {
    isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(isLandscape?20:4),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSearch(theme),
                Spacer(),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(YDRouter.BOOK_SOURCE_ADD)
                          .then((value) => _fetchListAndUpdate(null));
                    },
                    icon: Icon(
                      Icons.add_outlined,
                      color: theme.primaryColor,
                    ),
                    label: Text(
                      '添加书源',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: theme.textTheme.subtitle2!.fontSize),
                    )),
              ],
            ),
            VSpace(10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: showLoading
                    ? _buildLoading(context)
                    : _buildListContainer(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  Column _buildListContainer(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              HSpace(60),
              Text('名称/分组'),
              if(isLandscape)
                HSpace(140),
              if(isLandscape)
                Text('网站源'),
              Spacer(),
              Text('启用'),
              HSpace(20),
            ],
          ),
        ),
        Divider(
          thickness: 1,
          height: 1,
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: CupertinoScrollbar(
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (ctx, index) {
                  return _buildSourceItem(ctx, bookSourceList[index]);
                },
                separatorBuilder: (c, i) => Divider(),
                itemCount: bookSourceList.length,
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
        ),
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    var theme = Theme.of(context);
    return Row(
      children: [
        Checkbox(
          value: _selectCount == bookSourceList.length && _selectCount > 0,
          onChanged: (b) {
            _selectAllSource(b!);
          },
          activeColor: theme.primaryColor,
        ),
        Text(
          '全选 ($_selectCount/${bookSourceList.length})',
        ),
        Spacer(),
        OutlineButton(
          onPressed: () {
            _reverseSelect();
          },
          child: Text('反选'),
        ),
        HSpace(8),
        if(isLandscape)
          OutlineButton(
            onPressed: () {_deleteSelect();},
            child: Text('删除'),
          ),
        PopupMenuButton(
            onSelected: (k){
              switch(k){
                case 0:
                  _stateSelect(true);
                  break;
                case 1:
                  _stateSelect(false);
                  break;
                case 2:
                  BotToast.showText(text: '当前无法校验书源');
                  break;
                case 3:
                  _deleteSelect();
                  break;
              }
            },
            offset: Offset(0, -180),
            itemBuilder: (ctx) {
              return [
                PopupMenuItem(child: Text('启用所选'),value: 0,),
                PopupMenuItem(child: Text('禁用所选'),value: 1,),
                // PopupMenuItem(child: Text('校验所选'),value: 2,),
                if(!isLandscape)
                  PopupMenuItem(child: Text('删除所选'),value: 3,),
              ];
            }),
      ],
    );
  }

  Widget _buildLoading(BuildContext context) {
    var theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  Container _buildSearch(ThemeData theme) {
    return Container(
      height: 40,
      width: isLandscape?300:220,
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
                _fetchListAndUpdate(s);
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
                _fetchListAndUpdate(null);
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

  Widget _buildSourceItem(BuildContext context, BookSourceBean bean) {
    var theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (e){
        _showItemMenu(context,bean.id!,e.globalPosition);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Checkbox(
            value: bean.localSelect,
            onChanged: (b) {
              setState(() {
                _selectCount += b! ? 1 : -1;
                bean.localSelect = b;
              });
            },
            activeColor: theme.primaryColor,
          ),
          Container(
              width: 180,
              child: Text(
                "${bean.bookSourceName}${bean.bookSourceGroup != null ? '(${bean.bookSourceGroup})' : ''}",
                style: theme.textTheme.subtitle1,
              )),
          HSpace(20),
          if(isLandscape)
            Expanded(child: Text(bean.bookSourceUrl)),
          if(!isLandscape)
            Spacer(),
          Switch(
            value: bean.enabled,
            onChanged: (b) {
              bean.enabled = b;
              setState((){
                var helper = DatabaseHelper();
                helper.updateBookSourceStateById(bean.id!,b);
              });
            },
            activeColor: theme.primaryColor,
          )
        ],
      ),
    );
  }


  void _showItemMenu(BuildContext context,int sourceId, Offset position) async{
    var result = await showMenu(context: context, position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0), items: [
      PopupMenuItem(child: Text('校验书源'),value: 0,),
      PopupMenuItem(child: Text('复制到剪贴板'),value: 1,),
    ]);
    if(result == 0){
      _verifySource(sourceId);
    }else if(result == 1){
      _copySource(sourceId);
    }
  }

  void _copySource(int sourceId) async{
    print('copy..');

    var source = await _getSourceMap(sourceId);
    var s = jsonEncode(source);
    Clipboard.setData(ClipboardData(text: s));
    BotToast.showText(text: '已复制');

  }

  void _verifySource(int sourceId) async{
    var source = await _getSourceMap(sourceId);
    var cancel = BotToast.showLoading();
    var success = await SourceVerifyHelper().verify(BookSourceBean.fromJson(source), (progressText, done) {

    });
    cancel();
    BotToast.showText(text: success??false?'校验成功':'可能失效了');

  }

  dynamic _getSourceMap(int sourceId) async{
    var source = await DatabaseHelper().queryBookSourceMapById(sourceId);
    if(source == null){
      return;
    }
    source = Map.from(source);
    source.remove('_id');
    source['enabled'] = source['enabled'] == 1;
    source['enabledExplore'] = source['enabledExplore'] == 1;
    source['ruleExplore'] = jsonDecode(source['ruleExplore']);
    source['ruleSearch'] = jsonDecode(source['ruleSearch']);
    source['ruleBookInfo'] = jsonDecode(source['ruleBookInfo']);
    source['ruleToc'] = jsonDecode(source['ruleToc']);
    source['ruleContent'] = jsonDecode(source['ruleContent']);


    return Future.value(source);
  }

  dynamic _fetchListAndUpdate(String? title) async {
    if (title != null) {
      // _searchController.text = title.trim();
      if (title.trim().isEmpty) {
        title = null;
      }
    }
    showLoading = true;
    setState(() {});
    var helper = DatabaseHelper();
    bookSourceList = await helper.queryAllBookSource(title: title);
    setState(() {
      showLoading = false;
      _selectCount = 0;
    });
  }

  void _selectAllSource(bool select) {
    for (var s in bookSourceList) {
      s.localSelect = select;
    }
    if (select) {
      _selectCount = bookSourceList.length;
    } else {
      _selectCount = 0;
    }
    setState(() {});
  }

  void _reverseSelect() {
    _selectCount = 0;
    for (var s in bookSourceList) {
      s.localSelect = !s.localSelect;
      _selectCount += s.localSelect ? 1 : 0;
    }
    setState(() {});
  }

  void _deleteSelect() async{
    if(_selectCount==0){
      return;
    }
    List<int> ids = [];
    for (var value in bookSourceList) {
      if(value.localSelect){
        ids.add(value.id!);
      }
    }
    var helper = DatabaseHelper();
    await helper.deleteBookSourceByIds(ids);
    await _fetchListAndUpdate(null);
  }

  void _stateSelect(bool enabled) async{
    if(_selectCount==0){
      return;
    }
    List<int> ids = [];
    for (var value in bookSourceList) {
      if(value.localSelect){
        ids.add(value.id!);
      }
    }
    var helper = DatabaseHelper();
    await helper.updateBookSourceStateByIds(ids,enabled);
    await _fetchListAndUpdate(null);
  }
}
