import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/BookSourceBean.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
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
  List<BookSourceBean> bookSourceList = List<BookSourceBean>();
  bool showLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((value) => _fetchListAndUpdate());
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSearch(theme),
                Spacer(),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(YDRouter.BOOK_SOURCE_ADD);
                    },
                    icon: Icon(
                      Icons.add_outlined,
                      color: theme.primaryColor,
                    ),
                    label: Text(
                      '添加书源',
                      style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: theme.textTheme.subtitle2.fontSize),
                    )),
              ],
            ),
            VSpace(10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: theme.cardColor,borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
                child: showLoading?_buildLoading(context):_buildListContainer(context),
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
                        HSpace(140),
                        Text('网站源'),
                        Spacer(),
                        Text('启用'),
                        HSpace(20),
                      ],
                    ),
                  ),
                  Divider(thickness: 1,height: 1,),
                  Expanded(
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
                  Divider(height: 1,thickness: 1,),
                  _buildBottomBar(context),
                ],
              );
  }

  Widget _buildBottomBar(BuildContext context){
    var theme = Theme.of(context);
    return Row(
      children: [
        Checkbox(
          value: false,
          onChanged: (b) {

          },
          activeColor: theme.primaryColor,
        ),
        Text('全选 (0/${bookSourceList.length})',),
        Spacer(),
        OutlineButton(onPressed: (){},child: Text('反选'),),
        OutlineButton(onPressed: (){},child: Text('删除'),),
        PopupMenuButton(offset: Offset(0, -180),itemBuilder:(ctx){
          return [
            PopupMenuItem(child: Text('启用所选')),
            PopupMenuItem(child: Text('禁用所选')),
            PopupMenuItem(child: Text('校验所选')),

          ];
        }),
      ],
    );
  }

  Widget _buildLoading(BuildContext context){
    var theme = Theme.of(context);
    return Center(
      child: CircularProgressIndicator(backgroundColor: theme.primaryColor,),
    );
  }

  Container _buildSearch(ThemeData theme) {
    return Container(
      height: 40,
      width: 320,
      padding: EdgeInsets.only(left: 8, right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: theme.canvasColor,
      ),
      child: TextField(
        autofocus: false,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: '根据标题 搜索书源',
          prefixIconConstraints: BoxConstraints(minWidth: 24, maxHeight: 24),
          prefixIcon: Icon(
            Icons.search_outlined,
            color: theme.hintColor,
            size: 24,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSourceItem(BuildContext context, BookSourceBean bean) {
    var theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: bean.localSelect,
          onChanged: (b) {
            setState(() {
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
        Expanded(child: Text(bean.bookSourceUrl)),
        Switch(
          value: bean.enabled,
          onChanged: (b) {
            bean.enabled = b;
            setState(() {});
          },
          activeColor: theme.primaryColor,
        )
      ],
    );
  }

  dynamic _fetchListAndUpdate() async {
    showLoading = true;
    setState(() {

    });
    var helper = DatabaseHelper();
    bookSourceList = await helper.queryAllBookSource();
    setState(() {
      showLoading = false;
    });
  }
}
