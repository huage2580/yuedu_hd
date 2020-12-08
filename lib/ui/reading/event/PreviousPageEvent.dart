
import 'package:flutter/cupertino.dart';

class PreviousPageEvent extends ChangeNotifier{
  static PreviousPageEvent _instance;
  static PreviousPageEvent getInstance(){
    if(_instance == null){
      _instance = PreviousPageEvent._();
    }
    return _instance;
  }
  PreviousPageEvent._(){
    //pass
  }

  void emit(){
    notifyListeners();
  }
}