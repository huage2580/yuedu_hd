
import 'dart:async';

///锁定指定数量并发
class CountLock{
  int max = 1;
  int counter = 0;

  CountLock(this.max);

  Future? _lock;
  Completer? _completer;
  Completer? _allDoneCompleter;

  /// Whether this interceptor has been locked.
  bool get locked => _lock != null;

  /// Lock the interceptor.
  ///
  /// Once the request/response interceptor is locked, the incoming request/response
  /// will be added to a queue  before they enter the interceptor, they will not be
  /// continued until the interceptor is unlocked.
  Future? _lockMe(){
    if (!locked) {
      _completer = Completer();
      _lock = _completer?.future;
    }
    return _lock;
  }

  /// Unlock the interceptor. please refer to [lock()]
  void _unlockMe() {
    if (locked) {
      _completer?.complete();
      _lock = null;
    }
    if(counter == 0){
      _allDoneCompleter?.complete();
      _allDoneCompleter = null;
    }
  }
  Future waitDone() async{
    if(_allDoneCompleter!=null){
      return _allDoneCompleter?.future;
    }
    return Future.value(counter);
  }

  Future request() async{
    counter++;
    if(_allDoneCompleter==null){
      _allDoneCompleter = Completer();
    }
    // print('locker:$counter');
    if(counter > max){
     // print('lock!');
      return _lockMe();
    }else{
      return Future.value(counter);
    }
  }

  void release(){
    counter --;
    if(counter <= max){
      //print('unlock!');
      _unlockMe();
    }
  }

  /// Clean the interceptor queue.
  void clear([String msg = 'cancelled']) {
    if (locked) {
      _completer?.completeError(msg);
      _allDoneCompleter?.completeError(msg);
      _allDoneCompleter = null;
      _lock = null;
    }
  }

}