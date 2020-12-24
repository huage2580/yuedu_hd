
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
  int chapterId;

  void emit(String name,int cid){
    chapterName = name;
    chapterId = cid;
    notifyListeners();
  }
}