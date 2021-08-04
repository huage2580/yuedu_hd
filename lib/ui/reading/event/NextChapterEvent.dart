
import 'package:flutter/cupertino.dart';

class NextChapterEvent extends ChangeNotifier{
  static NextChapterEvent? _instance;
  static NextChapterEvent getInstance(){
    if(_instance == null){
      _instance = NextChapterEvent._();
    }
    return _instance!;
  }
  NextChapterEvent._(){
    //pass
  }

  void emit(){
    notifyListeners();
  }
}