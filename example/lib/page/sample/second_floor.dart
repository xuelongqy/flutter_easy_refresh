import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:example/generated/i18n.dart';

/// 二楼示例页面
class SecondFloorPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SecondFloorPageState();
  }
}

class SecondFloorPageState extends State<SecondFloorPage> {
  // 总数
  int _count = 20;
  LinkHeaderNotifier _linkNotifier;
  ValueNotifier<bool> _secondFloorOpen;

  @override
  void initState() {
    super.initState();
    _linkNotifier = LinkHeaderNotifier();
    _secondFloorOpen = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    super.dispose();
    _linkNotifier.dispose();
    _secondFloorOpen.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SecondFloorWidget(_linkNotifier, _secondFloorOpen),
          Expanded(
            child: EasyRefresh.custom(
              header: LinkHeader(
                _linkNotifier,
                extent: 70.0,
                triggerDistance: 70.0,
                completeDuration: Duration(milliseconds: 500),
              ),
              onRefresh: () async {
                if (_secondFloorOpen.value) return;
                await Future.delayed(Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _count = 20;
                    });
                  }
                });
              },
              onLoad: () async {
                await Future.delayed(Duration(seconds: 2), () {
                  if (mounted) {
                    setState(() {
                      _count += 20;
                    });
                  }
                });
              },
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 180.0,
                  pinned: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    title: Text(S.of(context).secondFloor),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SampleListItem();
                    },
                    childCount: _count,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 二楼视图
class SecondFloorWidget extends StatefulWidget {
  // Header连接通知器
  final LinkHeaderNotifier linkNotifier;
  // 二楼开启状态
  final ValueNotifier<bool> secondFloorOpen;

  const SecondFloorWidget(this.linkNotifier, this.secondFloorOpen, {Key key})
      : super(key: key);

  @override
  SecondFloorWidgetState createState() {
    return SecondFloorWidgetState();
  }
}

class SecondFloorWidgetState extends State<SecondFloorWidget> {
  // 触发二楼高度
  final double _openSecondFloorExtent = 100.0;
  // 指示器值
  double _indicatorValue = 0.0;

  // 二楼高度
  double _secondFloor = 0.0;
  // 显示展开收起动画
  bool _toggleAnimation = false;
  Duration _toggleAnimationDuration = Duration(milliseconds: 300);
  // 二楼是否打开
  bool _isOpen = false;

  RefreshMode get _refreshState => widget.linkNotifier.refreshState;
  double get _pulledExtent => widget.linkNotifier.pulledExtent;

  @override
  void initState() {
    super.initState();
    widget.linkNotifier.addListener(onLinkNotify);
  }

  void onLinkNotify() {
    setState(() {
      if (_refreshState == RefreshMode.armed ||
          _refreshState == RefreshMode.refresh) {
        _indicatorValue = null;
        // 判断是否到展开二楼
        if (widget.secondFloorOpen.value && !_toggleAnimation) {
          _isOpen = true;
          _secondFloor = MediaQuery.of(context).size.height;
          _toggleAnimation = true;
          Future.delayed(_toggleAnimationDuration, () {
            if (mounted) {
              setState(() {
                _toggleAnimation = false;
              });
            }
          });
        }
      } else if (_refreshState == RefreshMode.refreshed ||
          _refreshState == RefreshMode.done) {
        _indicatorValue = 1.0;
      } else {
        if (_refreshState == RefreshMode.inactive) {
          _indicatorValue = 0.0;
          _toggleAnimation = true;
          Future.delayed(_toggleAnimationDuration, () {
            if (mounted) {
              setState(() {
                _toggleAnimation = false;
              });
            }
          });
        } else {
          double indicatorValue = _pulledExtent / 70.0 * 0.8;
          _indicatorValue = indicatorValue < 0.8 ? indicatorValue : 0.8;
          // 判断是否到达打开二楼高度
          if (_refreshState == RefreshMode.drag) {
            if (_pulledExtent >= _openSecondFloorExtent) {
              widget.secondFloorOpen.value = true;
            } else {
              widget.secondFloorOpen.value = false;
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isOpen) {
          setState(() {
            _isOpen = false;
            _toggleAnimation = true;
            Future.delayed(_toggleAnimationDuration, () {
              if (mounted) {
                setState(() {
                  _toggleAnimation = false;
                });
              }
            });
          });
          return Future.value(false);
        }
        return Future.value(true);
      },
      child: AnimatedContainer(
        height: _isOpen
            ? _secondFloor
            : _refreshState == RefreshMode.inactive ? 0.0 : _pulledExtent,
        color: Colors.white,
        duration: _toggleAnimation
            ? _toggleAnimationDuration
            : Duration(milliseconds: 1),
        child: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Image.asset(
                  'assets/image/bg_second_floor.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            _isOpen
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                  )
                : Container(),
            Positioned(
              bottom: 0.0,
              left: 0.0,
              right: 0.0,
              child: AnimatedCrossFade(
                firstChild: Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                      bottom: 20.0,
                      top: 10.0,
                    ),
                    width: 24.0,
                    height: 24.0,
                    child: Offstage(
                      offstage: widget.secondFloorOpen.value,
                      child: CircularProgressIndicator(
                        value: _indicatorValue,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 2.4,
                      ),
                    ),
                  ),
                ),
                secondChild: Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(
                      bottom: 20.0,
                      top: 10.0,
                    ),
                    child: Offstage(
                      offstage: !widget.secondFloorOpen.value,
                      child: Text(
                        S.of(context).welcomeToSecondFloor,
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                crossFadeState: widget.secondFloorOpen.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
