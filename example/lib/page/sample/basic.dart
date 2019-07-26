import 'dart:async';

import 'package:example/widget/list_item.dart';
import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// 基本示例(经典样式)页面
class BasicPage extends StatefulWidget {
  /// 标题
  final String title;

  const BasicPage(this.title, {Key key}) : super(key: key);

  @override
  _BasicPageState createState() => _BasicPageState();
}
class _BasicPageState extends State<BasicPage> {
  EasyRefreshController _controller;
  ScrollController _scrollController;

  // 条目总数
  int _count = 20;
  // 反向
  bool _reverse = false;
  // 方向
  Axis _direction = Axis.vertical;
  // Header浮动
  bool _headerFloat = false;
  // 无限加载
  bool _enableInfiniteLoad = true;
  // 控制结束
  bool _enableControlFinish = false;
  // 任务独立
  bool _taskIndependence = false;
  // 震动
  bool _vibration = true;
  // 是否开启刷新
  bool _enableRefresh = true;
  // 是否开启加载
  bool _enableLoad = true;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) {
                return _buildModalMenu();
              },
            ),
          )
        ],
      ),
      body: Center(
        child: Container(
          height: _direction == Axis.vertical ? double.infinity : 210.0,
          child: EasyRefresh.custom(
            enableControlFinishRefresh: true,
            enableControlFinishLoad: true,
            taskIndependence: _taskIndependence,
            controller: _controller,
            scrollController: _scrollController,
            reverse: _reverse,
            scrollDirection: _direction,
            header: ClassicalHeader(
              enableInfiniteRefresh: false,
              refreshText: FlutterI18n.translate(context, 'pullToRefresh'),
              refreshReadyText: FlutterI18n.translate(context, 'releaseToRefresh'),
              refreshingText: FlutterI18n.translate(context, 'refreshing'),
              refreshedText: FlutterI18n.translate(context, 'refreshed'),
              refreshFailedText: FlutterI18n.translate(context, 'refreshFailed'),
              noMoreText: FlutterI18n.translate(context, 'noMore'),
              infoText: FlutterI18n.translate(context, 'updateAt'),
              bgColor: _headerFloat ? Theme.of(context).primaryColor : null,
              infoColor: _headerFloat ? Colors.black87 : Colors.teal,
              float: _headerFloat,
              enableHapticFeedback: _vibration,
            ),
            footer: ClassicalFooter(
              enableInfiniteLoad: _enableInfiniteLoad,
              loadText: FlutterI18n.translate(context, 'pushToLoad'),
              loadReadyText: FlutterI18n.translate(context, 'releaseToLoad'),
              loadingText: FlutterI18n.translate(context, 'loading'),
              loadedText: FlutterI18n.translate(context, 'loaded'),
              loadFailedText: FlutterI18n.translate(context, 'loadFailed'),
              noMoreText: FlutterI18n.translate(context, 'noMore'),
              infoText: FlutterI18n.translate(context, 'updateAt'),
              enableHapticFeedback: _vibration,
            ),
            onRefresh: _enableRefresh ? () async {
              await Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  _count = 20;
                });
                if (!_enableControlFinish) {
                  _controller.resetLoadState();
                  _controller.finishRefresh();
                }
              });
            }: null,
            onLoad: _enableLoad ? () async {
              await Future.delayed(Duration(seconds: 2), () {
                setState(() {
                  _count += 20;
                });
                if (!_enableControlFinish) {
                  _controller.finishLoad(noMore: _count >= 80);
                }
              });
            }: null,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return SampleListItem(
                      direction: _direction,
                      width: _direction == Axis.vertical
                          ? double.infinity : 150.0,
                    );
                  },
                  childCount: _count,
                ),
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: <Widget>[
        _enableControlFinish ? FlatButton(
            onPressed: () {
              _controller.resetLoadState();
              _controller.finishRefresh();
            },
            child: Text(FlutterI18n.translate(context, 'completeRefresh'),
                style: TextStyle(color: Colors.black)))
            : SizedBox(width: 0.0, height: 0.0,),
        _enableControlFinish ? FlatButton(
            onPressed: () {
              _controller.finishLoad(noMore: _count >= 80);
            },
            child: Text(FlutterI18n.translate(context, 'completeLoad'),
                style: TextStyle(color: Colors.black)))
            : SizedBox(width: 0.0, height: 0.0,),
        FlatButton(
            onPressed: () {
              _controller.callRefresh();
            },
            child: Text(FlutterI18n.translate(context, 'refresh'),
                style: TextStyle(color: Colors.black))),
        FlatButton(
            onPressed: () {
              _controller.callLoad();
            },
            child: Text(FlutterI18n.translate(context, 'loadMore'),
                style: TextStyle(color: Colors.black))),
      ],
    );
  }

  // 构建模态窗口菜单
  Widget _buildModalMenu() {
    return StatefulBuilder(
      builder: (context, state) {
        return EasyRefresh.custom(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                // 列表方向
                ListItem(
                  title: FlutterI18n.translate(context, 'direction'),
                  describe: FlutterI18n.translate(context, 'listDirection'),
                  rightWidget: Container(
                    child: Row(
                      children: <Widget>[
                        Text(FlutterI18n.translate(context, 'vertical')),
                        Radio<Axis>(
                          groupValue: _direction,
                          value: Axis.vertical,
                          onChanged: (axis) {
                            setState(() {
                              _direction = Axis.vertical;
                            });
                            state((){});
                          },
                        ),
                        Text(FlutterI18n.translate(context, 'horizontal')),
                        Radio<Axis>(
                          groupValue: _direction,
                          value: Axis.horizontal,
                          onChanged: (axis) {
                            setState(() {
                              _direction = Axis.horizontal;
                            });
                            state((){});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // 反向
                ListItem(
                  title: FlutterI18n.translate(context, 'reverse'),
                  describe: FlutterI18n.translate(context, 'listReverse'),
                  rightWidget: Center(
                    child: Switch(
                      value: _reverse,
                      onChanged: (reverse) {
                        setState(() {
                          _reverse = reverse;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
                // 无限加载
                ListItem(
                  title: FlutterI18n.translate(context, 'infiniteLoad'),
                  describe: FlutterI18n.translate(
                      context, 'infiniteLoadDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _enableInfiniteLoad,
                      onChanged: (infinite) {
                        setState(() {
                          _enableInfiniteLoad = infinite;
                        });
                        state((){});
                        _controller.resetLoadState();
                      },
                    ),
                  ),
                ),
                // 控制结束
                ListItem(
                  title: FlutterI18n.translate(context, 'controlFinish'),
                  describe: FlutterI18n.translate(
                      context, 'controlFinishDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _enableControlFinish,
                      onChanged: (control) {
                        setState(() {
                          _enableControlFinish = control;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
                // 任务独立
                ListItem(
                  title: FlutterI18n.translate(context, 'taskIndependence'),
                  describe: FlutterI18n.translate(
                      context, 'taskIndependenceDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _taskIndependence,
                      onChanged: (independence) {
                        setState(() {
                          _taskIndependence = independence;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
                // Header浮动
                ListItem(
                  title: FlutterI18n.translate(context, 'headerFloat'),
                  describe: FlutterI18n.translate(
                      context, 'headerFloatDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _headerFloat,
                      onChanged: (float) {
                        setState(() {
                          _headerFloat = float;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
                // 震动
                ListItem(
                  title: FlutterI18n.translate(context, 'vibration'),
                  describe: FlutterI18n.translate(
                      context, 'vibrationDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _vibration,
                      onChanged: (vibration) {
                        setState(() {
                          _vibration = vibration;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
                // 刷新开关
                ListItem(
                  title: FlutterI18n.translate(context, 'refreshSwitch'),
                  describe: FlutterI18n.translate(
                      context, 'refreshSwitchDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _enableRefresh,
                      onChanged: (refresh) {
                        setState(() {
                          _enableRefresh = refresh;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
                // 加载开关
                ListItem(
                  title: FlutterI18n.translate(context, 'loadSwitch'),
                  describe: FlutterI18n.translate(
                      context, 'loadSwitchDescribe'),
                  rightWidget: Center(
                    child: Switch(
                      value: _enableLoad,
                      onChanged: (load) {
                        setState(() {
                          _enableLoad = load;
                        });
                        state((){});
                      },
                    ),
                  ),
                ),
              ]),
            ),
          ],
        );
      },
    );
  }
}