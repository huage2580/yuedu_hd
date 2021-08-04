
import 'package:flutter/cupertino.dart';

class NextPageEvent extends ChangeNotifier{
  static NextPageEvent? _instance;
  static NextPageEvent getInstance(){
    if(_instance == null){
      _instance = NextPageEvent._();
    }
    return _instance!;
  }
  NextPageEvent._(){
    //pass
  }

  void emit(){
    notifyListeners();
  }
}