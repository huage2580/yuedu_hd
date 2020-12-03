

import 'package:yuedu_hd/ui/reading/DisplayPage.dart';

class DisplayCache{
  static DisplayCache _instance;
  static const MAX_CACHE_SIZE = 200;
  DisplayCache._init(){
    //
  }
  static DisplayCache getInstance(){
    if(_instance == null){
      _instance = DisplayCache._init();
    }
    return _instance;
  }

  //-----------------限制容量的缓存-----------
  var _cache = Map<int,DisplayPage>();


  /// maybe null
  DisplayPage get(int index){
    return _cache[index];
  }

  ///limit max cache size
  void put(int index,DisplayPage page){
    _cache[index] = page;
  }

}