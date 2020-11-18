
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/book_source_helper.dart';
import 'package:yuedu_hd/ui/widget/space.dart';
import 'dart:developer' as developer;

class PageSourceAdd extends StatefulWidget{
  @override
  _PageSourceAddState createState() => _PageSourceAddState();
}

class _PageSourceAddState extends State<PageSourceAdd> {
  bool showLoading = false;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios_outlined,color: theme.primaryColor,),padding: EdgeInsets.all(0), onPressed: (){
                  Navigator.of(context).pop();
                }),
                Expanded(child: _buildSearch(theme),),
                HSpace(8),
                FlatButton(onPressed: (){},
                  child: Text('导入',style: TextStyle(color: theme.accentColor),),
                  color: theme.primaryColorDark,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                ),
                HSpace(8),
                FlatButton(onPressed: (){
                  _testParseData();
                },
                  child: Text('粘贴板导入',style: TextStyle(color: theme.accentColor),),
                  color: theme.primaryColorDark,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                ),

              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text('''
书源的导入：
方式一：在上方输入网址，点击按钮开始导入。
方式二：复制配置文件到粘贴板，点击【粘贴板导入】按钮。
暂不支持编辑和修改，同网址书源每次导入均覆盖内容。
              ''',style: theme.textTheme.headline6,),
            ),
            VSpace(20),
            Text('调试日志:',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 12),),
            VSpace(20),
            Expanded(
                child: SingleChildScrollView(
                  child: Text(''),
                ),
            ),

          ],
        ),
      ),
    );
  }

  Container _buildSearch(ThemeData theme) {
    return Container(
      height: 40,
      padding: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: theme.canvasColor,
      ),
      child: TextField(
        maxLines: 1,
        decoration: InputDecoration(
          hintText: '输入网址，从网络导入',
          prefixIconConstraints: BoxConstraints(minWidth: 24, maxHeight: 24),
          prefixIcon: Icon(Icons.link_outlined,color: theme.hintColor,size: 24,),
          suffixIcon: showLoading?CupertinoActivityIndicator():null,
          border: InputBorder.none,
        ),
      ),
    );
  }


  dynamic _testParseData()async{
    setState(() {
      showLoading = true;

    });
    var req = await Dio().get('https://gitee.com/vpq/codes/9ji1mged7v54brhspz3of71/raw?blob_name=sy.json');
    var jsonStr = req.data;
    var helper = BookSourceHelper.getInstance();
    var list = await helper.parseSourceString(jsonStr);
    await helper.updateDataBases(list);
    developer.log(helper.getLog());

    setState(() {
      showLoading = false;

    });
  }

}