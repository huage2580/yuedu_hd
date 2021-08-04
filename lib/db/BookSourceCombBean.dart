
import 'package:yuedu_hd/db/BookSourceBean.dart';

class BookSourceCombBean{
  late int id;
  late int bookid;
  late int sourceid;
  late String bookurl;
  late int used;

  late BookSourceBean sourceBean;
  late String lastChapterName;

  BookSourceCombBean.fromMap(Map map){
    id = map['_id'];
    bookid = map['bookid'];
    sourceid = map['sourceid'];
    bookurl = map['bookurl'];
    used = map['used'];
  }

  BookSourceCombBean();
}