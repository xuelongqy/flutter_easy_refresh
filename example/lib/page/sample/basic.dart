import 'dart:async';

import 'package:example/widget/list_item.dart';
import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';

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
  // 顶部回弹
  bool _topBouncing = true;
  // 底部回弹
  bool _bottomBouncing = true;

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
            topBouncing: _topBouncing,
            bottomBouncing: _bottomBouncing,
            header: ClassicalHeader(
              enableInfiniteRefresh: false,
              bgColor: _headerFloat ? Theme.of(context).primaryColor : null,
              infoColor: _headerFloat ? Colors.black87 : Colors.teal,
              float: _headerFloat,
              enableHapticFeedback: _vibration,
            ),
            footer: ClassicalFooter(
              enableInfiniteLoad: _enableInfiniteLoad,
              enableHapticFeedback: _vibration,
            ),
            onRefresh: _enableRefresh
                ? () async {
                    await Future.delayed(Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _count = 20;
                        });
                        if (!_enableControlFinish) {
                          _controller.resetLoadState();
                          _controller.finishRefresh();
                        }
                      }
                    });
                  }
                : null,
            onLoad: _enableLoad
                ? () async {
                    await Future.delayed(Duration(seconds: 2), () {
                      if (mounted) {
                        setState(() {
                          _count += 20;
                        });
                        if (!_enableControlFinish) {
                          _controller.finishLoad(noMore: _count >= 80);
                        }
                      }
                    });
                  }
                : null,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return SampleListItem(
                      direction: _direction,
                      width:
                          _direction == Axis.vertical ? double.infinity : 150.0,
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
        _enableControlFinish
            ? FlatButton(
                onPressed: () {
                  _controller.resetLoadState();
                  _controller.finishRefresh();
                },
                child: Text(S.of(context).completeRefresh,
                    style: TextStyle(color: Colors.black)))
            : SizedBox(
                width: 0.0,
                height: 0.0,
              ),
        _enableControlFinish
            ? FlatButton(
                onPressed: () {
                  _controller.finishLoad(noMore: _count >= 80);
                },
                child: Text(S.of(context).completeLoad,
                    style: TextStyle(color: Colors.black)))
            : SizedBox(
                width: 0.0,
                height: 0.0,
              ),
        FlatButton(
            onPressed: () {
              _controller.callRefresh();
            },
            child: Text(S.of(context).refresh,
                style: TextStyle(color: Colors.black))),
        FlatButton(
            onPressed: () {
              _controller.callLoad();
            },
            child: Text(S.of(context).loadMore,
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
                  title: S.of(context).direction,
                  describe: S.of(context).listDirection,
                  rightWidget: Container(
                    child: Row(
                      children: <Widget>[
                        Text(S.of(context).vertical),
                        Radio<Axis>(
                          groupValue: _direction,
                          value: Axis.vertical,
                          onChanged: (axis) {
                            setState(() {
                              _direction = Axis.vertical;
                            });
                            state(() {});
                          },
                        ),
                        Text(S.of(context).horizontal),
                        Radio<Axis>(
                          groupValue: _direction,
                          value: Axis.horizontal,
                          onChanged: (axis) {
                            setState(() {
                              _direction = Axis.horizontal;
                            });
                            state(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // 反向
                ListItem(
                  title: S.of(context).reverse,
                  describe: S.of(context).listReverse,
                  rightWidget: Center(
                    child: Switch(
                      value: _reverse,
                      onChanged: (reverse) {
                        setState(() {
                          _reverse = reverse;
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // 无限加载
                ListItem(
                  title: S.of(context).infiniteLoad,
                  describe: S.of(context).infiniteLoadDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _enableInfiniteLoad,
                      onChanged: (infinite) {
                        setState(() {
                          _enableInfiniteLoad = infinite;
                        });
                        state(() {});
                        _controller.resetLoadState();
                      },
                    ),
                  ),
                ),
                // 控制结束
                ListItem(
                  title: S.of(context).controlFinish,
                  describe: S.of(context).controlFinishDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _enableControlFinish,
                      onChanged: (control) {
                        setState(() {
                          _enableControlFinish = control;
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // 任务独立
                ListItem(
                  title: S.of(context).taskIndependence,
                  describe: S.of(context).taskIndependenceDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _taskIndependence,
                      onChanged: (independence) {
                        setState(() {
                          _taskIndependence = independence;
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // Header浮动
                ListItem(
                  title: S.of(context).headerFloat,
                  describe: S.of(context).headerFloatDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _headerFloat,
                      onChanged: (float) {
                        setState(() {
                          _headerFloat = float;
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // 震动
                ListItem(
                  title: S.of(context).vibration,
                  describe: S.of(context).vibrationDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _vibration,
                      onChanged: (vibration) {
                        setState(() {
                          _vibration = vibration;
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // 刷新开关
                ListItem(
                  title: S.of(context).refreshSwitch,
                  describe: S.of(context).refreshSwitchDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _enableRefresh,
                      onChanged: (refresh) {
                        setState(() {
                          _enableRefresh = refresh;
                          if (!_topBouncing) {
                            _topBouncing = true;
                          }
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // 加载开关
                ListItem(
                  title: S.of(context).loadSwitch,
                  describe: S.of(context).loadSwitchDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _enableLoad,
                      onChanged: (load) {
                        setState(() {
                          _enableLoad = load;
                          if (!_bottomBouncing) {
                            _bottomBouncing = true;
                          }
                        });
                        state(() {});
                      },
                    ),
                  ),
                ),
                // 顶部回弹
                ListItem(
                  title: S.of(context).topBouncing,
                  describe: S.of(context).topBouncingDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _topBouncing,
                      onChanged: _enableRefresh
                          ? null
                          : (bouncing) {
                              setState(() {
                                _topBouncing = bouncing;
                              });
                              state(() {});
                            },
                    ),
                  ),
                ),
                // 底部回弹
                ListItem(
                  title: S.of(context).bottomBouncing,
                  describe: S.of(context).bottomBouncingDescribe,
                  rightWidget: Center(
                    child: Switch(
                      value: _bottomBouncing,
                      onChanged: _enableLoad
                          ? null
                          : (bouncing) {
                              setState(() {
                                _bottomBouncing = bouncing;
                              });
                              state(() {});
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
