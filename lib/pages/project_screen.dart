import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/config/GlobalConfig.dart';
import 'package:flutter_demo/mode/ProjectListTabBean.dart';
import 'package:flutter_demo/mode/ProjectListTabListDetailBean.dart';
import 'package:flutter_demo/net/service_method.dart';
import 'package:flutter_demo/pages/article_detail_page.dart';
import 'package:flutter_demo/pages/search_screen.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///项目
class ProjectScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProjectScreenState();
  }
}

class _ProjectScreenState extends State<ProjectScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  List<ProjectListTabData> _tabName = List();

  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _tabController = TabController(length: _tabName.length, vsync: this);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "项目",
          style: TextStyle(color: GlobalConfig.fontColor),
        ),
        bottom: TabBar(
            isScrollable: true,
            controller: _tabController,
            indicatorColor: GlobalConfig.fontColor,
            labelColor: GlobalConfig.fontColor,
            unselectedLabelColor: GlobalConfig.fontColor,
            tabs: _tabName.map((ProjectListTabData item) {
              return Tab(
                text: item.name,
              );
            }).toList()),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SearchPage();
              }));
            },
            child: Padding(
              padding: EdgeInsets.only(right: 15, left: 15),
              child:
                  Icon(Icons.search, color: GlobalConfig.fontColor, size: 20.0),
            ),
          )
        ],
      ),
      body: TabBarView(
        children: _tabName.map((ProjectListTabData item) {
          return Content(item.id);
        }).toList(),
        controller: _tabController,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  initData() async {
    request("projecttab").then((val) {
      ProjectListTabBean projectListTabBean = ProjectListTabBean.fromJson(val);
      List<ProjectListTabData> list = projectListTabBean.data;
      if (list != null && list.length > 0) {
        setState(() {
          _tabName = list;
        });
      }
    });
  }
}

class Content extends StatefulWidget {
  final int id;

  Content(this.id);

  @override
  State<StatefulWidget> createState() {
    return _ContentState();
  }
}

class _ContentState extends State<Content> {
  List<Datas> _listPage = List();
  int _currentIndex = 0;
  ScrollController _scrollController = ScrollController();
  GlobalKey<EasyRefreshState> _easyRefreshKey = GlobalKey<EasyRefreshState>();
  GlobalKey<RefreshHeaderState> _headerKey = GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = GlobalKey<RefreshFooterState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTabData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController?.dispose();
  }

  ///列表左侧图片
  Widget leftImg(index) {
    return Container(
      width: ScreenUtil().setWidth(330),
      alignment: Alignment.center,
      child: CachedNetworkImage(
        fit: BoxFit.fill,
        imageUrl: _listPage[index].envelopePic,
        errorWidget: (context, url, error) => Icon(Icons.error),
        placeholder: (context, url) => CircularProgressIndicator(),
      ),
    );
  }

  ///列表右侧content
  Widget rightContent(index) {
    return Expanded(
        child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _listPage[index].title,
              style: TextStyle(fontSize: ScreenUtil().setSp(38), color: GlobalConfig.fontColor),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _listPage[index].desc,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize:  ScreenUtil().setSp(34), color: GlobalConfig.fontColor),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "作者:" + _listPage[index].author,
                style: TextStyle(fontSize:  ScreenUtil().setSp(34), color: GlobalConfig.fontColor),
              ),
              Expanded(
                child: Text("时间:" + _listPage[index].niceDate,
                    style:
                        TextStyle(fontSize:  ScreenUtil().setSp(34), color: GlobalConfig.fontColor)),
              ),
            ],
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
        child: Container(
            margin: EdgeInsets.all(5),
            width: ScreenUtil().width,
            height: ScreenUtil().height,
            child: EasyRefresh(
              key: _easyRefreshKey,
              behavior: ScrollOverBehavior(),
              refreshHeader: ClassicsHeader(
                key: _headerKey,
                bgColor: GlobalConfig.dark
                    ? GlobalConfig.searchBackgroundColor
                    : Colors.transparent,
                textColor: GlobalConfig.fontColor,
                moreInfoColor: GlobalConfig.fontColor,
                showMore: true,
              ),
              refreshFooter: ClassicsFooter(
                key: _footerKey,
                bgColor: GlobalConfig.searchBackgroundColor,
                textColor: GlobalConfig.fontColor,
                moreInfoColor: GlobalConfig.fontColor,
                showMore: true,
              ),
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemExtent: 180,
                  itemCount: _listPage.length,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: Card(
                        elevation: 1,
                        color: GlobalConfig.cardBackgroundColor,
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Center(
                            child: Row(
                              children: <Widget>[
                                leftImg(index),
                                rightContent(index)
                              ],
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ArticleDetailPage(
                              title: _listPage[index].title,
                              url: _listPage[index].link);
                        }));
                      },
                    );
                  }),
              onRefresh: () async {
                getTabData();
              },
              loadMore: () async {
                getMoreTabData();
              },
            )));
  }

  getTabData() async {
    _currentIndex = 0;
    int _cid = widget.id;
    projectTabData(_currentIndex,_cid).then((val){
      ProjectListTabListDetailBean projectListTabListDetailBean =
      ProjectListTabListDetailBean.fromJson(val);
      List<Datas> list = projectListTabListDetailBean.data.datas;
      if (list != null && list.length > 0) {
        setState(() {
          _listPage = list;
        });
      }
    });
  }

   getMoreTabData() async {
    _currentIndex++;
    int _cid = widget.id;
    projectTabData(_currentIndex,_cid).then((val){
      ProjectListTabListDetailBean projectListTabListDetailBean =
      ProjectListTabListDetailBean.fromJson(val);
      List<Datas> list = projectListTabListDetailBean.data.datas;
      if (list != null && list.length > 0) {
        setState(() {
          _listPage.addAll(list);
        });
      }
    });
  }
}
