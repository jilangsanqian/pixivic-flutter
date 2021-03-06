import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:pixivic/page/pic_page.dart';
import 'package:pixivic/widget/papp_bar.dart';

class HistoryPage extends StatefulWidget {
  @override
  HistoryPageState createState() => HistoryPageState();

  HistoryPage();

}

class HistoryPageState extends State<HistoryPage> {
  List<Tab> tabs = <Tab>[
    Tab(
      text: '近期',
    ),
    Tab(
      text: '更早',
    )
  ];

  @override
  void initState() {
    print('HistoryPage Created');
    print(widget.key);
    super.initState();
  }

  @override
  void dispose() {
    print('HistoryPage Disposed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PappBar(title: '历史记录'),
      body: Container(
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: _tabViewer(),
      ),
    );
  }

  Widget _tabViewer() {
    return DefaultTabController(
      length: 2,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Material(
              child: Container(
                  height: ScreenUtil().setHeight(30),
                  width: ScreenUtil().setWidth(324),
                  child: TabBar(
                    labelColor: Colors.blueAccent[200],
                    tabs: tabs,
                  ))),
          Container(
            height: ScreenUtil().setHeight(491),
            width: ScreenUtil().setWidth(324),
            child: TabBarView(
              children: tabs.map((Tab tab) {
                if(tab.text == '近期') {
                  return PicPage.history(
//                    funOne: true,
                  );
                }
                else if(tab.text == '更早') {
                  return PicPage.oldHistory(
//                    funOne: true,
                  );
                }
                else {
                  return Container();
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
