

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

import 'DisplayConfig.dart';

typedef OnReadingStyleChanged = Function();
typedef OnMoreClick = Function();


///阅读样式调整的弹出菜单
class StyleMenu extends StatefulWidget{
  final OnReadingStyleChanged onReadingStyleChanged;
  final OnMoreClick onMoreClick;

  const StyleMenu({Key key, this.onReadingStyleChanged, this.onMoreClick}) : super(key: key);
  @override
  _StyleMenuState createState() => _StyleMenuState();
}

class _StyleMenuState extends State<StyleMenu> {
  var config = DisplayConfig.getDefault();

  @override
  Widget build(BuildContext context) {

    config = DisplayConfig.getDefault();
    var theme = Theme.of(context);
    //配置内容
    bool isVerticalScroll = config.isVertical == 1;
    bool isTwoPage = config.isSinglePage == 0;

    //
    return CupertinoScrollbar(
      child: SingleChildScrollView(
        child: Container(
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
                  GestureDetector(child: Icon(CupertinoIcons.square_split_1x2,size: 40,color: isVerticalScroll?theme.primaryColor:theme.canvasColor,),onTap: (){
                    config.isVertical = 1;
                    _notifyStyleChanged();
                  },),
                  HSpace(16),
                  GestureDetector(child: Icon(CupertinoIcons.square_split_2x1,size: 40,color: !isVerticalScroll?theme.primaryColor:theme.canvasColor,),onTap: (){
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
                  GestureDetector(child: Icon(CupertinoIcons.rectangle_expand_vertical,size: 40,color: !isTwoPage?theme.primaryColor:theme.canvasColor,),onTap: (){
                    config.isSinglePage = 1;
                    _notifyStyleChanged();
                  },),
                  HSpace(16),
                  GestureDetector(child: Icon(CupertinoIcons.book_fill,size: 40,color: isTwoPage?theme.primaryColor:theme.canvasColor,),onTap: (){
                    config.isSinglePage = 0;
                    _notifyStyleChanged();
                  },),
                ],
              ),
              Divider(),
              Text('颜色:',style: theme.textTheme.headline6,),
              VSpace(8),
              Container(
                height: 40,
                width: double.maxFinite,
                child: _buildColorList(context),
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
                child: GestureDetector(child: Text('更多设置 >'),onTap: (){
                  widget.onMoreClick();
                },),
              ),
            ],
          ),
        ),
      ),
    );
  }


  ///颜色列表
  ListView _buildColorList(BuildContext context) {
    return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildColorItem(context, Color(config.backgroundColor), Color(config.textColor),isSelected: true),
              _buildColorItem(context, Color(0xffCCE8CF), Colors.black),
              _buildColorItem(context, Color(0xff373737), Color(0xffcecece)),
              _buildColorItem(context, Color(0xff2a2c37), Color(0xffcaccdf)),
              _buildColorItem(context, Color(0xfff5f5f5), Color(0xff151920)),
              _buildColorItem(context, Color(0xffFFFFFF), Color(0xff000000)),
            ],
          );
  }

  Widget _buildColorItem(BuildContext context,Color bgColor,Color textColor,{bool isSelected = false}){
    return  GestureDetector(
      onTap: () async{
        if(isSelected){


        }else{
          config.backgroundColor = bgColor.value;
          config.textColor = textColor.value;
          config.titleColor = config.textColor;
          _notifyStyleChanged();
        }
      },
      child: Container(
        margin: EdgeInsets.only(right: 4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child:Icon(isSelected?Icons.done:CupertinoIcons.textformat,size: 24,color: textColor,),
      ),
    );
  }

  void _notifyStyleChanged(){
    setState(() {
      widget.onReadingStyleChanged();
    });
    DatabaseHelper().saveConfig(config);
  }

}

