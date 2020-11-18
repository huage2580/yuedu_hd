
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';

import '../widget/space.dart';

///书源列表
class PageSourceList extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _StateSourceList();
  }

}

class _StateSourceList extends State<PageSourceList>{
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
                    onPressed: (){
                      Navigator.of(context).pushNamed(YDRouter.BOOK_SOURCE_ADD);
                    },
                    icon: Icon(Icons.add_outlined,color: theme.primaryColor,),
                    label: Text('添加书源',style: TextStyle(color:theme.primaryColor,fontSize: theme.textTheme.subtitle2.fontSize),)
                ),
              ],
            ),
            VSpace(10),
            Expanded(child:  Placeholder(),)
          ],
        ),
      ),
    );
  }

  Container _buildSearch(ThemeData theme) {
    return Container(
                height: 40,
                width: 320,
                padding: EdgeInsets.only(left: 8,right: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: theme.canvasColor,
                ),
                child: TextField(
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: '根据标题 搜索书源',
                    prefixIconConstraints: BoxConstraints(minWidth: 24, maxHeight: 24),
                    prefixIcon: Icon(Icons.search_outlined,color: theme.hintColor,size: 24,),
                    border: InputBorder.none,
                  ),
                ),
              );
  }

}