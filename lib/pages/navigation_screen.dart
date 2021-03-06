import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_demo/eventbus/eventBus.dart';
import 'package:flutter_demo/mode/NavigationDetailBean.dart';
import 'package:flutter_demo/net/service_method.dart';
import 'package:flutter_demo/provider/bottom_cat_model.dart';
import 'package:flutter_demo/routers/app.dart';
import 'package:flutter_demo/routers/routers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

/**
 * 导航
 */
class NavigationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NavigationState();
  }
}

class _NavigationState extends State<NavigationScreen> with AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<BottomCatModel>(
      builder: (context, model, _) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "导航",
              style: TextStyle(color: model.fontColor),
            ),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  App.router.navigateTo(context, Routers.search);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 15, left: 15),
                  child: Icon(Icons.search, color: model.fontColor, size: 20.0),
                ),
              )
            ],
          ),
          body: SafeArea(
              child: FutureBuilder(
                  future: request('nav'),
                  builder: (context,val){
                    if(val.hasData){
                      NavigationDetailBean navigationDetailBean =
                      NavigationDetailBean.fromJson(val.data);
                      List<Data> _listData = navigationDetailBean.data;
                      return Container(
                        child: Row(
                          children: <Widget>[
                            LeftCategoryNav(_listData, model),
                            CategoryGoodsList(_listData, model)
                          ],
                        ),
                      );
                    }else{
                      return Container(
                        child: Text(""),
                      );
                    }
                  })),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

/**
 * 右侧数据列表
 */
class CategoryGoodsList extends StatefulWidget {
  List<Data> _rightNavData;
  BottomCatModel model;

  CategoryGoodsList(this._rightNavData, this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CategoryRightState();
  }
}

class _CategoryRightState extends State<CategoryGoodsList> {
  int _leftIndex;
  @override
  Widget build(BuildContext context) {
    _leftIndex = Provider.of<BottomCatModel>(context).navigationindex;
    return Expanded(
        child: Container(
            alignment: Alignment.topLeft,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
                        child: Text(widget._rightNavData[_leftIndex].name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: ScreenUtil().setSp(36),
                                color: widget.model.fontColor,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  Wrap(
                    spacing: 3,
                    runSpacing: 1,
                    alignment: WrapAlignment.start,
                    children: List.generate(
                        widget._rightNavData[_leftIndex].articles.length, (i) {
                      var random = Random(i + _leftIndex);
                      var _color = Color.fromRGBO(
                          random.nextInt(255),
                          random.nextInt(255),
                          random.nextInt(255),
                          widget.model.dark ? 0.2 : 1);
                      return FlatButton(
                        onPressed: () => {
                              App.router.navigateTo(context,
                                  "${Routers.web}?title=${Uri.encodeComponent(widget._rightNavData[_leftIndex].articles[i].title)}&url=${Uri.encodeComponent(widget._rightNavData[_leftIndex].articles[i].link)}")
                            },
                        child: Text(
                          widget._rightNavData[_leftIndex].articles[i].title,
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(32),
                              color: widget.model.fontColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        color: _color,
                        textColor: widget.model.fontColor,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color: _color,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                      );
                    }),
                  )
                ],
              ),
            )));
  }
}

/**
 * 左侧导航
 */
class LeftCategoryNav extends StatefulWidget {
  List<Data> _leftNavData;
  BottomCatModel model;

  LeftCategoryNav(this._leftNavData, this.model);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LeftCategoryNavState();
  }
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  bool isClick = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int navigationindex= Provider.of<BottomCatModel>(context).navigationindex;
    return Container(
      width: ScreenUtil().setWidth(240),
      decoration: BoxDecoration(
          border: Border(right: BorderSide(width: 1, color: Colors.black12))),
      child: ListView.builder(
        itemCount: widget._leftNavData.length,
        itemBuilder: (context, index) {
          isClick = (index == navigationindex ) ? true : false;
          return InkWell(
            onTap: () {
              setState(() {
                Provider.of<BottomCatModel>(context).setNavigationIndex(index);
              });
            },
            child: Container(
              alignment: Alignment.center,
              height: ScreenUtil().setHeight(130),
              decoration: BoxDecoration(
                  color: isClick
                      ? widget.model.searchBackgroundColor
                      : widget.model.cardBackgroundColor,
                  border: Border(
                      bottom: BorderSide(width: 1, color: Colors.black12))),
              child: Text(
                widget._leftNavData[index].name,
                style: TextStyle(
                    fontSize: ScreenUtil().setSp(36),
                    color: widget.model.fontColor),
              ),
            ),
          );
        },
      ),
    );
  }
}
