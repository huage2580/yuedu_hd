
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


//单双页，页眉页脚，左右中间间距
class DisplayPage extends StatelessWidget{
  static const STATUS_LOADING = 11;
  static const STATUS_ERROR = 12;
  static const STATUS_SUCCESS = 13;


  final int status;
  final String text;

  DisplayPage(this.status, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Stack(
        children: [
          _buildContent(),
          Container(
            child: Center(//占位内容
              child: Text('加载中'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(){
    return Text(text??'???');
  }

}