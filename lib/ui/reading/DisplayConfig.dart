
//阅读的配置项目
class DisplayConfig{
  int isSinglePage = 0;
  int isVertical = 0;
  double margin = 10;//外边距
  double inSizeMargin = 20;//双页的话，行内边距
  int backgroundColor = 0xfff5f5f5;//阅读背景色
  double textSize = 20;//正文字体大小
  int textColor = 0xff000000;//正文字体颜色
  double titleSize = 24;//标题大小
  int titleColor = 0xff000000;//标题颜色
  double titleMargin = 0;//标题和正文的间距
  int spaceParagraph = 4;//段落开头空格

  static DisplayConfig _default;

  static DisplayConfig getDefault(){
    if(_default == null){
      _default = DisplayConfig();
    }
    return _default;
  }

}