

import 'dart:collection';

import 'package:yuedu_hd/ui/reading/DisplayPage.dart';

///缓存清除的时候，按章节来清除,每次清除都要保证清空了一个章节
class DisplayCache{
  static DisplayCache? _instance;
  static const MAX_CACHE_CHAPTER = 20;//最多缓存20章内容
  DisplayCache._init(){
    //
  }
  static DisplayCache getInstance(){
    if(_instance == null){
      _instance = DisplayCache._init();
    }
    return _instance!;
  }

  //-----------------限制容量的缓存-----------
  var _cache = LinkedHashMap<int,DisplayPage>();
  List<List<int>> _chapterList = [];


  /// maybe null
  DisplayPage? get(int index){
    return _cache[index];
  }

  ///limit max cache size
  void put(int index,DisplayPage page){
    _cache[index] = page;
  }

  ///压入缓存
  void packChapter(List<int> pageIndexArray){
    _chapterList.add(pageIndexArray);
    if(_chapterList.length > MAX_CACHE_CHAPTER){//大于缓存，移除一半内容
      var half = (_chapterList.length/2).ceil();
      //清空视图缓存
      _chapterList.take(half).forEach((element) {
        for (var index in element) {
          _cache.remove(index);
        }
      });
    }
  }

  void clear(){
    _cache.clear();
    _chapterList.clear();
  }

}