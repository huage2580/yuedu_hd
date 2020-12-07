
//阅读的配置项目
class DisplayConfig{
  int isSinglePage = 0;
  int isVertical = 0;
  double margin = 10;//外边距
  double inSizeMargin = 20;//双页的话，行内边距
  double textSize = 20;//正文字体大小
  int textColor = 0xff000000;//正文字体颜色
  double titleSize = 20;//标题大小
  int titleColor = 0xff000000;//标题颜色

  static DisplayConfig getDefault(){
    return DisplayConfig();
  }

}