import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/common/api.dart';
import 'package:wanandroid_flutter/entity/project_entity.dart';
import 'package:wanandroid_flutter/entity/project_list_entity.dart';
import 'package:wanandroid_flutter/http/httpUtil.dart';
import 'package:wanandroid_flutter/pages/articleDetail.dart';
import 'package:wanandroid_flutter/res/colors.dart';

class ProjectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _ProjectPageState();
  }
}

class _ProjectPageState extends State<ProjectPage>
    with SingleTickerProviderStateMixin {
  TabController _controller; //tab控制器
  int _currentIndex = 0; //选中下标

  List<ProjectData> _datas = new List(); //tab集合
  List<ProjectListDataData> _listDatas = new List(); //内容集合

  @override
  void initState() {
    super.initState();
    getHttp();
  }

  void getHttp() async {
    try {
      var response = await HttpUtil().get(Api.PROJECT);
      Map userMap = json.decode(response.toString());
      var projectEntity = new ProjectEntity.fromJson(userMap);

      setState(() {
        _datas = projectEntity.data;
      });

      getDetail();

      //初始化controller并添加监听
      _controller = TabController(vsync: this, length: _datas.length);
      _controller.addListener(() => _onTabChanged());
    } catch (e) {
      print(e);
    }
  }

  ///
  /// tab改变监听
  ///
  _onTabChanged() {
    if (_controller.indexIsChanging) {
      if (this.mounted) {
        //赋值 并更新数据
        this.setState(() {
          _currentIndex = _controller.index;
        });
        getDetail();
      }
    }
  }

  ///
  /// 根据tab下标获取数据
  ///
  void getDetail() async {
    try {
      var data = {"cid": _datas[_currentIndex].id};
      var response = await HttpUtil().get(Api.PROJECT_LIST, data: data);
      Map userMap = json.decode(response.toString());
      var projectListEntity = new ProjectListEntity.fromJson(userMap);

      setState(() {
        _listDatas = projectListEntity.data.datas;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _datas.length,
      child: Scaffold(
        appBar: TabBar(
          controller: _controller,
          //控制器
          labelColor: YColors.colorPrimaryDark,
          //选中的颜色
          labelStyle: TextStyle(fontSize: 16),
          //选中的样式
          unselectedLabelColor: YColors.color_666,
          //未选中的颜色
          unselectedLabelStyle: TextStyle(fontSize: 14),
          //未选中的样式
          indicatorColor: YColors.colorPrimary,
          //下划线颜色
          isScrollable: true,
          //是否可滑动
          //tab标签
          tabs: _datas.map((ProjectData choice) {
            return Tab(
              text: choice.name,
            );
          }).toList(),
          //点击事件
          onTap: (int i) {
            print(i);
          },
        ),
        body: TabBarView(
          controller: _controller,
          children: _datas.map((ProjectData choice) {
            return ListView.builder(
                itemCount: _listDatas.length,
                itemBuilder: (BuildContext context, int position) {
                  return getRow(position);
                });
          }).toList(),
        ),
      ),
    );
  }

  Widget getRow(int i) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(10),
        child: Card(
          elevation: 5,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Image.network(_listDatas[i].envelopePic),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: new Text(
                          _listDatas[i].title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          _listDatas[i].desc,
                          style:
                              TextStyle(fontSize: 14, color: YColors.color_666),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(_listDatas[i].niceDate,
                                    style: TextStyle(fontSize: 14)),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                _listDatas[i].author,
                                style: TextStyle(fontSize: 14),
                                textAlign: TextAlign.right,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        //点击item跳转到详情
        Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => new ArticleDetail(
                  title: _listDatas[i].title, url: _listDatas[i].link)),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
