

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NumberPicker extends StatefulWidget{
  final num minValue;
  final num maxValue;
  final num initialValue;
  final int decimal;//小数点后位数

  const NumberPicker({Key? key, required this.minValue, required this.maxValue, required this.initialValue, required this.decimal}) : super(key: key);
  NumberPicker.decimal({Key? key, required this.minValue, required this.maxValue, required this.initialValue,this.decimal = 1});
  NumberPicker.integer({Key? key, required this.minValue, required this.maxValue, required this.initialValue,this.decimal = 0});

  @override
  _NumberPickerState createState() => _NumberPickerState();

}

class _NumberPickerState extends State<NumberPicker> {
  var currSelect = 0;
  var arrays = <double>[];
  var _scrollController;

  @override
  void initState() {
    super.initState();
    // 0-1 10*10
    // 1-0.1 10*10*10
    // 2- 0.01 10*10*10*10
    var step = 10 / pow(10, widget.decimal + 1);
    print(step);
    var counter = 0;
    for(var i = widget.minValue;i<=widget.maxValue;i+=step){
      var n = num.parse(i.toStringAsFixed(widget.decimal)).toDouble();
      if(n==widget.initialValue){
        currSelect = counter;
      }
      arrays.add(n);
      counter++;
    }
    _scrollController = FixedExtentScrollController(initialItem: currSelect);
  }

  @override
  Widget build(BuildContext context) {

      return AlertDialog(
        content: Container(
          height: 200,
          child: CupertinoPicker.builder(scrollController: _scrollController,itemExtent: 40, onSelectedItemChanged: (index){
            currSelect = index;
          }, itemBuilder: (context,index){
            return Container(height: 40,child: Center(child: Text('${arrays[index].toStringAsFixed(widget.decimal)}')));
          },childCount: arrays.length,),
        ),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text('取消')),
          TextButton(onPressed: (){
            if(widget.decimal == 0){
              Navigator.of(context).pop(arrays[currSelect].toInt());
            }else{
              Navigator.of(context).pop(arrays[currSelect]);
            }
          }, child: Text('确定')),
        ],
      );
  }
}