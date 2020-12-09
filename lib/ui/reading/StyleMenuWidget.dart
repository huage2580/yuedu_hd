

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

import 'DisplayConfig.dart';

typedef OnReadingStyleChanged = Function();


///阅读样式调整的弹出菜单
class StyleMenu extends StatefulWidget{
  final OnReadingStyleChanged onReadingStyleChanged;

  const StyleMenu({Key key, this.onReadingStyleChanged}) : super(key: key);
  @override
  _StyleMenuState createState() => _StyleMenuState();
}

class _StyleMenuState extends State<StyleMenu> {
  @override
  Widget build(BuildContext context) {

    var theme = Theme.of(context);
    var config = DisplayConfig.getDefault();
    //配置内容
    bool isVerticalScroll = config.isVertical == 1;
    bool isTwoPage = config.isSinglePage == 0;

    //
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('滚动方向:',style: theme.textTheme.headline6,),
              HSpace(16),
              GestureDetector(child: Icon(CupertinoIcons.square_split_1x2_fill,size: 40,color: isVerticalScroll?theme.primaryColor:theme.canvasColor,),onTap: (){
                config.isVertical = 1;
                _notifyStyleChanged();
              },),
              HSpace(16),
              GestureDetector(child: Icon(CupertinoIcons.square_split_2x1_fill,size: 40,color: !isVerticalScroll?theme.primaryColor:theme.canvasColor,),onTap: (){
                config.isVertical = 0;
                _notifyStyleChanged();
              },),
            ],
          ),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('内容布局:',style: theme.textTheme.headline6,),
              HSpace(16),
              Icon(CupertinoIcons.rectangle_fill,size: 40,color: !isTwoPage?theme.primaryColor:theme.canvasColor,),
              HSpace(16),
              Icon(CupertinoIcons.book_fill,size: 40,color: isTwoPage?theme.primaryColor:theme.canvasColor,),
            ],
          ),
          Divider(),
          Text('颜色:',style: theme.textTheme.headline6,),
          VSpace(8),
          Container(
            height: 40,
            width: double.maxFinite,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildColorItem(context, Colors.white, Colors.black,isSelected: true),
                _buildColorItem(context, Colors.black45, Colors.white70),
                _buildColorItem(context, Colors.blueGrey, Colors.black),
                _buildColorItem(context, Colors.lightGreen, Colors.orange),
                _buildColorItem(context, Colors.white, Colors.black),
                _buildColorItem(context, Colors.white, Colors.black),
                _buildColorItem(context, Colors.white, Colors.black),
                _buildColorItem(context, Colors.white, Colors.black),
              ],
            ),
          ),
          Divider(),
          Row(
            children: [
              Text('正文:',style: theme.textTheme.headline6,),
              IconButton(icon: Icon(CupertinoIcons.minus_circle), onPressed: (){
                config.textSize = config.textSize - 1;
                _notifyStyleChanged();
              }),
              Text('${config.textSize}sp'),
              IconButton(icon: Icon(CupertinoIcons.add_circled), onPressed: (){
                config.textSize = config.textSize + 1;
                _notifyStyleChanged();
              })
            ],
          ),
          Row(
            children: [
              Text('标题:',style: theme.textTheme.headline6,),
              IconButton(icon: Icon(CupertinoIcons.minus_circle), onPressed: (){
                config.titleSize = config.titleSize - 1;
                _notifyStyleChanged();
              }),
              Text('${config.titleSize}sp'),
              IconButton(icon: Icon(CupertinoIcons.add_circled), onPressed: (){
                config.titleSize = config.titleSize + 1;
                _notifyStyleChanged();
              })
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text('更多设置 >'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(BuildContext context,Color bgColor,Color textColor,{bool isSelected = false}){
    return  Container(
      margin: EdgeInsets.only(right: 8),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child:Icon(isSelected?Icons.done:CupertinoIcons.textformat,size: 24,color: textColor,),
    );
  }

  void _notifyStyleChanged(){
    setState(() {
      widget.onReadingStyleChanged();
    });
  }

}
