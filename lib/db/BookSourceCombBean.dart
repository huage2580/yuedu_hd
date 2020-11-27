
import 'package:yuedu_hd/db/BookSourceBean.dart';

class BookSourceCombBean{
  int id;
  int bookid;
  int sourceid;
  String bookurl;
  int used;

  BookSourceBean sourceBean;
  String lastChapterName;

  BookSourceCombBean.fromMap(Map map){
    id = map['_id'];
    bookid = map['bookid'];
    sourceid = map['sourceid'];
    bookurl = map['bookurl'];
    used = map['used'];
  }

  BookSourceCombBean();
}