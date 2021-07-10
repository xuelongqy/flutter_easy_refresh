import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/src/notifier/indicator_notifier.dart';
import './physics/scroll_physics.dart';
import './behavior/scroll_behavior.dart';

class EasyRefresh extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 刷新回调
  final FutureOr Function()? onRefresh;

  /// 加载回调
  final FutureOr Function()? onLoad;

  const EasyRefresh({
    Key? key,
    required this.child,
    this.onRefresh,
    this.onLoad,
  }) : super(key: key);

  @override
  _EasyRefreshState createState() => _EasyRefreshState();
}

class _EasyRefreshState extends State<EasyRefresh> {
  late ERScrollBehavior _scrollBehavior;

  /// 用户偏移通知器(记录是否为用户滚动)
  ValueNotifier<bool> _userOffsetNotifier = ValueNotifier<bool>(false);

  /// Header通知器
  late HeaderNotifier _headerNotifier;

  /// Footer通知器
  late FooterNotifier _footerNotifier;

  @override
  void initState() {
    super.initState();
    _headerNotifier = HeaderNotifier(
      triggerOffset: 70,
      clamping: true,
      userOffsetNotifier: _userOffsetNotifier,
    );
    _footerNotifier = FooterNotifier(
      triggerOffset: 70,
      clamping: false,
      userOffsetNotifier: _userOffsetNotifier,
    );
    _scrollBehavior = ERScrollBehavior(ERScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
    ));
    // Future(() {
    //   PrimaryScrollController.of(context)!.addListener(() {
    //     print(PrimaryScrollController.of(context)!.position.pixels);
    //   });
    // });
    _userOffsetNotifier.addListener(() {
      print(_userOffsetNotifier.value);
    });
    _headerNotifier.addListener(() {
      if (_headerNotifier.mode == IndicatorMode.processing) {
        Future.sync(widget.onRefresh!).whenComplete(() {
          _headerNotifier.updateMode(IndicatorMode.done);
        });
      }
      setState(() {});
    });
    _footerNotifier.addListener(() {
      if (_footerNotifier.mode == IndicatorMode.processing) {
        Future.sync(widget.onLoad!).whenComplete(() {
          _footerNotifier.updateMode(IndicatorMode.done);
        });
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userOffsetNotifier.dispose();
  }

  /// 构建Header容器
  Widget _buildHeaderView() {
    if (_headerNotifier.axis == null || _headerNotifier.axisDirection == null) {
      return SizedBox();
    }
    // 方向
    final axis = _headerNotifier.axis!;
    final axisDirection = _headerNotifier.axisDirection!;
    return Positioned(
      top: axis == Axis.vertical
          ? axisDirection == AxisDirection.down
              ? 0
              : null
          : 0,
      bottom: axis == Axis.vertical
          ? axisDirection == AxisDirection.up
              ? 0
              : null
          : 0,
      left: axis == Axis.horizontal
          ? axisDirection == AxisDirection.right
              ? 0
              : null
          : 0,
      right: axis == Axis.horizontal
          ? axisDirection == AxisDirection.left
              ? 0
              : null
          : 0,
      child: Container(
        color: Colors.blue,
        width: axis == Axis.vertical ? double.infinity : _headerNotifier.offset,
        height:
            axis == Axis.vertical ? _headerNotifier.offset : double.infinity,
      ),
    );
  }

  /// 构建Footer容器
  Widget _buildFooterView() {
    if (_headerNotifier.axis == null || _headerNotifier.axisDirection == null) {
      return SizedBox();
    }
    // 方向
    final axis = _headerNotifier.axis!;
    final axisDirection = _headerNotifier.axisDirection!;
    return Positioned(
      top: axis == Axis.vertical
          ? axisDirection == AxisDirection.up
              ? 0
              : null
          : 0,
      bottom: axis == Axis.vertical
          ? axisDirection == AxisDirection.down
              ? 0
              : null
          : 0,
      left: axis == Axis.horizontal
          ? axisDirection == AxisDirection.left
              ? 0
              : null
          : 0,
      right: axis == Axis.horizontal
          ? axisDirection == AxisDirection.right
              ? 0
              : null
          : 0,
      child: Container(
        color: Colors.blue,
        width: axis == Axis.vertical ? double.infinity : _footerNotifier.offset,
        height:
            axis == Axis.vertical ? _footerNotifier.offset : double.infinity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: _scrollBehavior,
          child: widget.child,
        ),
        _buildHeaderView(),
        _buildFooterView(),
      ],
    );
  }
}
