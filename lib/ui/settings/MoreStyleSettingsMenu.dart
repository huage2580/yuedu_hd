


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/db/databaseHelper.dart';
import 'package:yuedu_hd/ui/reading/DisplayConfig.dart';
import 'package:yuedu_hd/ui/widget/ColorPickerDialog.dart';
import 'package:yuedu_hd/ui/widget/NumberPicker.dart';


///阅读样式的更多设置
class MoreStyleSettingsMenu extends StatefulWidget{
  @override
  _MoreStyleSettingsMenuState createState() => _MoreStyleSettingsMenuState();
}

class _MoreStyleSettingsMenuState extends State<MoreStyleSettingsMenu> {
  @override
  Widget build(BuildContext context) {
    var config = DisplayConfig.getDefault();
    var theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(title: Text('页边距 左'),subtitle:Text('阅读页面和四周的边距'),trailing: Text('${config.marginLeft}dp'),onTap: () async{
          int result = await showDialog(context: context,builder: (_)=>NumberPicker.integer(minValue: 0, maxValue: 200, initialValue: config.marginLeft));
          if(result!=null){
            config.marginLeft = result.toDouble();
            _saveConfig();
          }
        },),
        ListTile(title: Text('页边距 右'),subtitle:Text('阅读页面和四周的边距'),trailing: Text('${config.marginRight}dp'),onTap: () async{
          int result = await showDialog(context: context,builder: (_)=>NumberPicker.integer(minValue: 0, maxValue: 200, initialValue: config.marginRight));
          if(result!=null){
            config.marginRight = result.toDouble();
            _saveConfig();
          }
        },),
        ListTile(title: Text('页边距 上'),subtitle:Text('阅读页面和四周的边距'),trailing: Text('${config.marginTop}dp'),onTap: () async{
          int result = await showDialog(context: context,builder: (_)=>NumberPicker.integer(minValue: 0, maxValue: 300, initialValue: config.marginTop));
          if(result!=null){
            config.marginTop = result.toDouble();
            _saveConfig();
          }
        },),
        ListTile(title: Text('页边距 下'),subtitle:Text('阅读页面和四周的边距'),trailing: Text('${config.marginBottom}dp'),onTap: () async{
          int result = await showDialog(context: context,builder: (_)=>NumberPicker.integer(minValue: 0, maxValue: 100, initialValue: config.marginBottom));
          if(result!=null){
            config.marginBottom = result.toDouble();
            _saveConfig();
          }
        },),
        ListTile(title: Text('标题和正文间距'),subtitle:Text('标题和正文之间的留白'),trailing: Text('${config.titleMargin}dp'),onTap: () async{
          int result = await showDialog(context: context,builder: (_)=>NumberPicker.integer(minValue: 0, maxValue: 100, initialValue: config.titleMargin));
          if(result!=null){
            config.titleMargin = result.toDouble();
            _saveConfig();
          }
        },),
        ListTile(title: Text('行间距'),subtitle:Text('正文行距，缩放倍数1为基准'),trailing: Text('${config.lineSpace}'),onTap: () async{
          var result = await showDialog(context: context,builder: (_)=>NumberPicker.decimal(minValue: 0.8, maxValue: 3, initialValue: config.lineSpace));
          if(result!=null){
            config.lineSpace = result;
            _saveConfig();
          }
        },),
        ListTile(title: Text('段落留白'),subtitle:Text('段落开头的空格数'),trailing: Text('${config.spaceParagraph}'),onTap: () async{
          var result = await showDialog(context: context,builder: (_)=>NumberPicker.integer(minValue: 0, maxValue: 10, initialValue: config.spaceParagraph));
          if(result!=null){
            config.spaceParagraph = result;
            _saveConfig();
          }
        },),
        ListTile(title: Text('正文颜色'),trailing: ColorCircleWidget(Color(config.textColor)),onTap: (){
          showDialog<Color>(context: context,builder: (_)=>ColorPickerDialog(initColor: Color(config.textColor),)).then((value){
            if(value!=null){
              config.textColor = value.value;
              _saveConfig();
            }
          });
        },),
        ListTile(title: Text('标题颜色'),trailing: ColorCircleWidget(Color(config.titleColor)),onTap: (){
          showDialog<Color>(context: context,builder: (_)=>ColorPickerDialog(initColor: Color(config.titleColor),)).then((value){
            if(value!=null){
              config.titleColor = value.value;
              _saveConfig();
            }
          });
        },),
        ListTile(title: Text('背景色'),trailing: ColorCircleWidget(Color(config.backgroundColor)),onTap: (){
          showDialog<Color>(context: context,builder: (_)=>ColorPickerDialog(initColor: Color(config.backgroundColor),)).then((value){
            if(value!=null){
              config.backgroundColor = value.value;
              _saveConfig();
            }
          });
        },),
        SwitchListTile(title: Text('标题加粗'),activeColor: theme.primaryColor,value: config.isTitleBold==1,onChanged: (b){
          config.isTitleBold = b?1:0;
          _saveConfig();
        },),
        SwitchListTile(title: Text('正文加粗'),activeColor: theme.primaryColor,value: config.isTextBold==1,onChanged: (b){
          config.isTextBold = b?1:0;
          _saveConfig();
        },),
        ListTile(title: Text('自定义字体'),subtitle:Text('选择使用内置的字体'),trailing: Text('${config.fontPath}'),onTap: () async{
          var result = await showDialog(context: context,builder: (ctx)=>SimpleDialog(
            title: Text("选择字体"),
            children: _getFontList(config,ctx),
          ));

          if(result!=null){
            config.fontPath = result;
            _saveConfig();
          }
        },),
      ],
    );
  }

  List<Widget> _getFontList(DisplayConfig config, BuildContext ctx){
    var f = config.fontPath;
    var fonts = [{"name":"系统默认","font":""},
      {"name":"HarmonyOS_Sans","font":"HarmonyOS_Sans"},
      {"name":"汉字拼音体","font":"Hanzi-Pinyin"},
      {"name":"站酷快乐体","font":"zcool_happy"},
      {"name":"青松手写体","font":"handwrite"},];
    List<Widget> items = [];
    for (var value in fonts) {
      items.add(Container(
        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
        child: GestureDetector(
          onTap: (){
            Navigator.of(ctx).pop(value["font"]);
          },
          child: Row(
            children: [
              Expanded(child: Text(value["name"]!,style: TextStyle(fontSize: 24),)),
              if(value["font"] == f)
                Icon(Icons.done)
            ],
          ),
        ),
      ));
    }
    return items;
  }

  void _saveConfig(){
    var config = DisplayConfig.getDefault();
    DatabaseHelper().saveConfig(config);
    setState(() {

    });
  }


}



class ColorCircleWidget extends StatelessWidget {
  final Color color;

  const ColorCircleWidget(this.color,{
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    );
  }
}