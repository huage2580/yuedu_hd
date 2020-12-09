
import 'package:flutter/cupertino.dart';

class ChapterChangedEvent extends ChangeNotifier{
  static ChapterChangedEvent _instance;
  static ChapterChangedEvent getInstance(){
    if(_instance == null){
      _instance = ChapterChangedEvent._();
    }
    return _instance;
  }
  ChapterChangedEvent._(){
    //pass
  }

  String chapterName;

  void emit(String name){
    chapterName = name;
    notifyListeners();
  }
}