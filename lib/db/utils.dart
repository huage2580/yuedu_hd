import 'package:dio/dio.dart';
import 'package:gbk_codec/gbk_codec.dart';

class Utils{
  Utils._();

  static String gbkDecoder(List<int> responseBytes, RequestOptions options, ResponseBody responseBody) {
    return gbk_bytes.decode(responseBytes);
  }

  static String checkLink(String host,String input){
    if(input == null || input.isEmpty){
      return "";
    }
    if(input.startsWith('http')){
      return input;
    }else{
      return host + input;
    }
  }

}