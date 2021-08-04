
import 'package:flutter/cupertino.dart';

class PreviousChapterEvent extends ChangeNotifier{
  static PreviousChapterEvent? _instance;
  static PreviousChapterEvent getInstance(){
    if(_instance == null){
      _instance = PreviousChapterEvent._();
    }
    return _instance!;
  }
  PreviousChapterEvent._(){
    //pass
  }

  void emit(){
    notifyListeners();
  }
}