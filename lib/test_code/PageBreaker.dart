
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

///指定显示区域宽高
///对于长文本进行分页（二分法）
///配置字体等属性
class PageBreaker{
  //正文
  TextSpan contentString;
  //章节标题
  TextSpan titleString;
  //绘制区域大小
  Size drawSize;

  PageBreaker(this.contentString, this.titleString, this.drawSize);

  List<YDPage> splitPage(){
    var results = List<YDPage>();
    //当前页面的文字
    String currText = contentString.text;
    //剩余文字
    String overText = '';

    while(currText.length > 0){
      TextPainter titlePainter;
      //计算标题
      if(results.isEmpty){
        titlePainter = TextPainter(text: titleString,textDirection: TextDirection.ltr,textAlign: TextAlign.center);
        titlePainter.layout(minWidth:drawSize.width,maxWidth: drawSize.width);
      }
      var titleOffset = titlePainter==null?0.0:titlePainter.height+30;
      //计算内容
      var maxIndex = currText.length - 1;
      var minIndex = 0;
      var maybeIndex = 0;
      //二分得出最后需要截取的位置
      while(true){//maxIndex-minIndex > 1
        maybeIndex = ((maxIndex - minIndex)/2).truncate() + minIndex;
        var maybeText = currText.substring(0,maybeIndex);
        var tempSpan = TextSpan(text: maybeText,style: contentString.style);
        var contentPainter = TextPainter(text: tempSpan,textDirection: TextDirection.ltr,);
        contentPainter.layout(maxWidth: drawSize.width);
        var maybeHeight = contentPainter.height;
        if(maybeHeight > drawSize.height - titleOffset){//超过了限制高度
          maxIndex = maybeIndex;
        }else{//没超过
          if(minIndex == maybeIndex){
            break;
          }
          minIndex = maybeIndex;
        }
      }

      overText = currText.substring(maybeIndex);
      currText = currText.substring(0,maybeIndex);
      if(currText.trim().isEmpty){
        break;
      }
      developer.log('-----------------------------------');
      developer.log(currText);
      developer.log('-----------------------------------');
      var textPainter = TextPainter(text: TextSpan(text: currText,style: contentString.style),textDirection: TextDirection.ltr,);
      textPainter.layout(maxWidth: drawSize.width);
      var tempPage = YDPage(titleOffset,titlePainter, textPainter);
      results.add(tempPage);

      currText = overText;
    }


    return results;
  }


}

class YDPage{
  //只有第一页会有的标题
  double titleOffset = 0;
  TextPainter titlePainter;
  TextPainter pagePainter;

  YDPage(this.titleOffset, this.titlePainter, this.pagePainter);
}