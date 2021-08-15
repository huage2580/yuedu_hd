
//阅读的配置项目
class DisplayConfig{
  int isSinglePage = 1;
  int isVertical = 0;
  double marginLeft = 20;//外边距
  double marginTop = 20;//外边距
  double marginRight = 20;//外边距
  double marginBottom = 20;//外边距

  double inSizeMargin = 40;//双页的话，页内边距
  int backgroundColor = 0xfff5f5f5;//阅读背景色
  double textSize = 18;//正文字体大小
  int textColor = 0xff000000;//正文字体颜色
  double titleSize = 24;//标题大小
  int titleColor = 0xff000000;//标题颜色
  double titleMargin = 0;//标题和正文的间距
  int spaceParagraph = 4;//段落开头空格

  double lineSpace = 1.2;//行距
  int isTitleBold = 1;//标题加粗
  int isTextBold = 0;//正文加粗
  String? fontPath = "";//选择字体

  static DisplayConfig? _default;

  static DisplayConfig getDefault(){
    if(_default == null){
      _default = DisplayConfig._();
    }
    return _default!;
  }

  DisplayConfig._(){
    //pass
  }

  DisplayConfig.fromMap(Map map){
    isSinglePage = map['isSinglePage'];
    isVertical = map['isVertical'];

    marginLeft = map['marginLeft'];
    marginTop = map['marginTop'];
    marginRight = map['marginRight'];
    marginBottom = map['marginBottom'];

    inSizeMargin = map['inSizeMargin'];
    backgroundColor = map['backgroundColor'];
    textSize = map['textSize'];
    textColor = map['textColor'];
    titleSize = map['titleSize'];
    titleColor = map['titleColor'];
    titleMargin = map['titleMargin'];
    spaceParagraph = map['spaceParagraph'];
    lineSpace = map['lineSpace'];
    isTitleBold = map['isTitleBold'];
    isTextBold = map['isTextBold'];
    fontPath = map['fontPath'];

    _default = this;
  }

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map['isSinglePage'] = isSinglePage;
    map['isVertical'] = isVertical;
    map['marginLeft'] = marginLeft;
    map['marginTop'] = marginTop;
    map['marginRight'] = marginRight;
    map['marginBottom'] = marginBottom;
    map['inSizeMargin'] = inSizeMargin;
    map['backgroundColor'] = backgroundColor;
    map['textSize'] = textSize;
    map['textColor'] = textColor;
    map['titleSize'] = titleSize;
    map['titleColor'] = titleColor;
    map['titleMargin'] = titleMargin;
    map['spaceParagraph'] = spaceParagraph;
    map['lineSpace'] = lineSpace;
    map['isTitleBold'] = isTitleBold;
    map['isTextBold'] = isTextBold;
    map['fontPath'] = fontPath;
    return map;
  }
}