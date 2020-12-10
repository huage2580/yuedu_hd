
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/download/BookDownloader.dart';

class PageDownLoad extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        height: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('下载队列',style: Theme.of(context).textTheme.subtitle1,),
            Divider(),
            Container(child: DownloadInfoWidget()),
          ],
        ),
      ),
    );
  }

}

class DownloadInfoWidget extends StatefulWidget{

  const DownloadInfoWidget({Key key}) : super(key: key);

  @override
  _DownloadInfoWidgetState createState() => _DownloadInfoWidgetState();
}

class _DownloadInfoWidgetState extends State<DownloadInfoWidget> {
  BookDownloader downloader;
  @override
  void initState() {
    downloader = BookDownloader.getInstance();
    downloader.downLoadCallBack = (){
      setState(() {
        print('download!');
      });
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(downloader.chapters.isEmpty){
      return Container(child: Center(child: Text('没有下载任务...',style: Theme.of(context).textTheme.headline4,)));
    }
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Text('${downloader.bookInfoBean.name} 待缓存章节: ${downloader.chapters.length}',style: Theme.of(context).textTheme.headline5,),
              Spacer(),
              IconButton(icon: Icon(Icons.stop), onPressed: (){
                downloader.stop();
              })
            ],
          ),
        ),
        Divider(),
      ],
    );
  }

  @override
  void dispose() {
    downloader.downLoadCallBack = (){};
    super.dispose();
  }
}