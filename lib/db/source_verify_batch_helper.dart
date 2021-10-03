
import 'dart:convert';

import 'BookSourceBean.dart';
import 'databaseHelper.dart';
import 'source_verify_helper.dart';

typedef void OnVerifyBatchProgress(String progressText);


class SourceVerifyBatchHelper{

  bool working = true;

  Future<int> verify(List<int> sourceIds,OnVerifyBatchProgress progress) async{
    var helper = DatabaseHelper();
    working = true;
    //for loop
    for(var i=0;i<sourceIds.length;i++){
      var sourceId = sourceIds[i];
      if(!working){
        break;
      }
      progress('[${i+1}/${sourceIds.length}]');
      var source = await _getSourceMap(sourceId);
      try{
        var success = await SourceVerifyHelper().verify(BookSourceBean.fromJson(source), (progressText, done) {

        });
        if(!(success??false)){
          await helper.updateBookSourceStateById(sourceId,false);
        }
      }catch(e){
        print(e);
      }

    }
    //查询书源
    //校验
    //回调通知
    //结束
    return Future.value(0);

  }


  dynamic _getSourceMap(int sourceId) async{
    var source = await DatabaseHelper().queryBookSourceMapById(sourceId);
    if(source == null){
      return;
    }
    source = Map.from(source);
    source.remove('_id');
    source['enabled'] = source['enabled'] == 1;
    source['enabledExplore'] = source['enabledExplore'] == 1;
    source['ruleExplore'] = jsonDecode(source['ruleExplore']);
    source['ruleSearch'] = jsonDecode(source['ruleSearch']);
    source['ruleBookInfo'] = jsonDecode(source['ruleBookInfo']);
    source['ruleToc'] = jsonDecode(source['ruleToc']);
    source['ruleContent'] = jsonDecode(source['ruleContent']);


    return Future.value(source);
  }

}