import 'package:flutter/material.dart';
import 'package:yuedu_hd/ui/YDRouter.dart';
import 'package:yuedu_hd/ui/widget/space.dart';
import 'package:yuedu_hd/ui/style/ycolors.dart';

class PageBookShelf extends StatefulWidget {
  @override
  _PageBookShelfState createState() => _PageBookShelfState();
}

class _PageBookShelfState extends State<PageBookShelf>
    with SingleTickerProviderStateMixin {
  var _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    tabs: [
                      Tab(
                        text: '全部',
                      ),
                      Tab(
                        text: '分组一',
                      ),
                      Tab(
                        text: '分组二',
                      ),
                    ],
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    labelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                    unselectedLabelStyle:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    labelColor: theme.textTheme.headline6.color,
                  ),
                ),
                PopupMenuButton(
                  tooltip: '排序方式',
                  itemBuilder: (ctx) {
                    return [
                      PopupMenuItem(
                        child: Text('默认排序'),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: Text('添加顺序'),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text('最后更新'),
                        value: 2,
                      ),
                    ];
                  },
                  child: IgnorePointer(
                    child: TextButton.icon(
                        onPressed: (){},
                        icon: Icon(Icons.sort_outlined),
                        label: Text('默认排序'),),
                  ),
                ),
              ],
            ),
            VSpace(4),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: YColors.border_color, width: 5),
                color: theme.cardColor,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  _buildList(),
                  Container(
                    margin: EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(YDRouter.BOOK_ADD);
                        },
                        child: Icon(Icons.add),
                        backgroundColor: theme.primaryColorDark,
                        foregroundColor: theme.canvasColor,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return Center(
      child: Text('test'),
    );
  }
}
