import 'package:flutter/widgets.dart';

class VSpace extends StatelessWidget{
  final double height;


  VSpace(this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: Size(0,height),);
  }
}

class HSpace extends StatelessWidget{
  final double width;


  HSpace(this.width);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(size: Size(width,0),);
  }
}
