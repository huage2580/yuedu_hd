
import 'package:flutter/widgets.dart';

class ReloadEvent extends ChangeNotifier{

  static ReloadEvent? _instance;

  static ReloadEvent getInstance(){
    if(_instance == null){
      _instance = ReloadEvent._();
    }
    return _instance!;
  }

  ReloadEvent._(){
    //pass
  }

  int pageIndex = -1;

  void reload(int index){
    pageIndex = index;
    notifyListeners();
  }
}