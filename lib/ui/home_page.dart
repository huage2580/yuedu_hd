import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/book_source/page_source_add.dart';
import 'package:yuedu_hd/ui/book_source/page_source_list.dart';
import 'package:yuedu_hd/ui/bookshelf/page_add_book.dart';
import 'package:yuedu_hd/ui/bookshelf/page_bookshelf.dart';
import 'package:yuedu_hd/ui/download/page_download.dart';
import 'package:yuedu_hd/ui/explore/page_explore.dart';
import 'package:yuedu_hd/ui/settings/page_settings.dart';
import 'package:yuedu_hd/ui/widget/space.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeState();
  }
}

class HomeState extends State<HomePage> {
  static const PAGE_BOOK = 0;
  static const PAGE_EXPLORE = 1;
  static const PAGE_SOURCE = 2;
  static const PAGE_SETTINGS = 3;
  static const PAGE_DOWNLOAD = 4;

  int currPage = 0;
  var homeContainerKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    // SystemChrome.setPreferredOrientations([ 	 //强制横屏
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.landscapeRight
    // ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS||Theme.of(context).platform == TargetPlatform.macOS;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: themeData.backgroundColor,
      body: OrientationBuilder(builder: (context,orientation){
        if(orientation == Orientation.landscape){
          return _buildLandscape(context, themeData, isIOS);
        }else{
          return _buildPortrait(context, themeData, isIOS);
        }
      },),
    );
  }

  Stack _buildLandscape(BuildContext context, ThemeData themeData, bool isIOS) {
    return Stack(
      children: [
        Row(
          children: [
            SizedBox(width: 180,),
            Expanded(child: _buildHomeContainer(context))
          ],
        ),
        Container(
          width: 180,
          decoration: BoxDecoration(
              color: themeData.cardColor,
              // boxShadow: <BoxShadow>[
              //   BoxShadow(
              //     color: themeData.shadowColor,
              //     offset: Offset(-1, 1),
              //     blurRadius: 8.0,
              //   ),
              // ],
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(isIOS?0:15),
                  bottomRight: Radius.circular(isIOS?0:15))),
          child: _buildMenu(context),
        ),
      ],
    );
  }

  Widget _buildPortrait(BuildContext context,ThemeData themeData, bool isIOS){
    return Stack(
      children: [
        Container(margin: EdgeInsets.only(bottom: 60),child: _buildHomeContainer(context)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 60,
            decoration: BoxDecoration(color: themeData.cardColor,),
            child: _buildPortraitMenu(context),
          ),
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Column(
      children: [
        VSpace(16),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "阅读",
                style: themeData.textTheme.headline4,
              ),
              HSpace(4),
              Text(
                "HD",
                style: TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
        VSpace(40),
        _HomeMenuItem(
          Icons.book_outlined,
          "书架",
          isSelected: currPage == PAGE_BOOK,
          onTap: () {
            switchPageTo(PAGE_BOOK);
          },
        ),
        // _HomeMenuItem(
        //   Icons.explore_outlined,
        //   "发现",
        //   isSelected: currPage == PAGE_EXPLORE,
        //   onTap: () {
        //     switchPageTo(PAGE_EXPLORE);
        //   },
        // ),
        _HomeMenuItem(
          Icons.arrow_circle_down_outlined,
          "下载",
          isSelected: currPage == PAGE_DOWNLOAD,
          onTap: () {
            switchPageTo(PAGE_DOWNLOAD);
          },
        ),
        _HomeMenuItem(
          Icons.cloud_circle_outlined,
          "书源",
          isSelected: currPage == PAGE_SOURCE,
          onTap: () {
            switchPageTo(PAGE_SOURCE);
          },
        ),
        Spacer(),
        _HomeMenuItem(
          Icons.settings_outlined,
          "设置",
          isSelected: currPage == PAGE_SETTINGS,
          onTap: () {
            switchPageTo(PAGE_SETTINGS);
          },
        ),
        VSpace(16)
      ],
    );
  }

  Widget _buildPortraitMenu(BuildContext context){
    return Row(
      children: [
        Expanded(child: _HomeMenuItem(
          Icons.book_outlined,
          "书架",
          isSelected: currPage == PAGE_BOOK,
          onTap: () {
            switchPageTo(PAGE_BOOK);
          },
          orientation: Orientation.portrait,
        ),),
        Expanded(child:  _HomeMenuItem(
          Icons.arrow_circle_down_outlined,
          "下载",
          isSelected: currPage == PAGE_DOWNLOAD,
          onTap: () {
            switchPageTo(PAGE_DOWNLOAD);
          },
          orientation: Orientation.portrait,

        ),
        ),
        Expanded(child:  _HomeMenuItem(
          Icons.cloud_circle_outlined,
          "书源",
          isSelected: currPage == PAGE_SOURCE,
          onTap: () {
            switchPageTo(PAGE_SOURCE);
          },
          orientation: Orientation.portrait,

        ),
        ),
        Expanded(child: _HomeMenuItem(
          Icons.settings_outlined,
          "设置",
          isSelected: currPage == PAGE_SETTINGS,
          onTap: () {
            switchPageTo(PAGE_SETTINGS);
          },
          orientation: Orientation.portrait,
        ),
        ),
      ],
    );
  }

  void switchPageTo(int target) {
    if (currPage == target) {
      return;
    }
    currPage = target;
    switch(target){
      case PAGE_BOOK:
        setState(() {
          homeContainerKey.currentState.pushNamedAndRemoveUntil(YDRouter.BOOKSHELF,ModalRoute.withName(YDRouter.BOOKSHELF));
        });
        break;
      case PAGE_SOURCE:
        setState(() {
          homeContainerKey.currentState.pushNamedAndRemoveUntil(YDRouter.BOOK_SOURCE_LIST,ModalRoute.withName(YDRouter.BOOK_SOURCE_LIST));
        });
        break;
      case PAGE_EXPLORE:
        setState(() {
          homeContainerKey.currentState.pushNamedAndRemoveUntil(YDRouter.EXPLORE,ModalRoute.withName(YDRouter.EXPLORE));
        });
        break;
      case PAGE_SETTINGS:
        setState(() {
          homeContainerKey.currentState.pushNamedAndRemoveUntil(YDRouter.SETTINGS,ModalRoute.withName(YDRouter.SETTINGS));
        });
        break;
      case PAGE_DOWNLOAD:
        setState(() {
          homeContainerKey.currentState.pushNamedAndRemoveUntil(YDRouter.DOWNLOAD,ModalRoute.withName(YDRouter.DOWNLOAD));
        });
        break;


    }

  }
  ///右边的内容区域
  Widget _buildHomeContainer(BuildContext ctx) {
    return Container(
      child: MaterialApp(
        navigatorKey: homeContainerKey,
        theme: Theme.of(ctx),
        initialRoute: YDRouter.BOOKSHELF,
        routes: <String,WidgetBuilder>{
          YDRouter.BOOKSHELF:(context)=>PageBookShelf(),
          YDRouter.BOOK_SOURCE_LIST:(context)=>PageSourceList(),
          YDRouter.BOOK_SOURCE_ADD:(context)=>PageSourceAdd(),
          YDRouter.EXPLORE:(context)=>PageExplore(),
          YDRouter.SETTINGS:(context)=>PageSettings(),
          YDRouter.BOOK_ADD:(context)=>PageAddBook(),
          YDRouter.DOWNLOAD:(context)=>PageDownLoad(),
        },
      ),
    );
  }
}

class _HomeMenuItem extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final String text;
  final Function onTap;
  final Orientation orientation;

  const _HomeMenuItem(
    this.icon,
    this.text, {
    Key key,
    this.isSelected = false,
    this.onTap,this.orientation = Orientation.landscape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: _menuItemWidget(themeData),
    );
  }

  Widget _menuItemWidget(themeData){
    if(orientation == Orientation.landscape){
      return _buildLandScapeItem(themeData);
    }else{
      return _buildPortraitItem(themeData);
    }
  }

  Container _buildLandScapeItem(ThemeData themeData) {
    return Container(
      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
      margin: EdgeInsets.only(left: 8, right: 8, top: 4),
      decoration: isSelected
          ? BoxDecoration(
              color: themeData.primaryColorLight,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            )
          : null,
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: isSelected ? themeData.primaryColor : null,
          ),
          HSpace(4),
          Expanded(
              child: Text(
            text,
            style: TextStyle(
                fontSize: themeData.textTheme.headline5.fontSize,
                color: isSelected ? themeData.primaryColor : null),
          )),
        ],
      ),
    );
  }

  Container _buildPortraitItem(ThemeData themeData) {
    return Container(
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? themeData.primaryColor : null,
          ),
          VSpace(4),
          Text(
            text,
            style: TextStyle(
                fontSize: themeData.textTheme.subtitle2.fontSize,
                color: isSelected ? themeData.primaryColor : null),
          ),
        ],
      ),
    );
  }

}
