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
    _headerNotifier = HeaderNotifier(70, _userOffsetNotifier);
    _footerNotifier = FooterNotifier(70, _userOffsetNotifier);
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
      print(_headerNotifier.offset);
      setState(() {});
      if (_headerNotifier.state == IndicatorState.processing) {
        Future.sync(widget.onRefresh!).whenComplete(() {
          _headerNotifier.updateState(IndicatorState.done);
        });
      }
    });
    _footerNotifier.addListener(() {
      print(_footerNotifier.offset);
      setState(() {});
      print(_footerNotifier.state);
      if (_footerNotifier.state == IndicatorState.processing) {
        Future.sync(widget.onLoad!).whenComplete(() {
          _footerNotifier.updateState(IndicatorState.done);
        });
      }
    });
    widget.onRefresh!;
  }

  @override
  void dispose() {
    super.dispose();
    _userOffsetNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.blue,
            width: double.infinity,
            height: _headerNotifier.offset,
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom,
          left: 0,
          right: 0,
          child: Container(
            color: Colors.blue,
            width: double.infinity,
            height: _footerNotifier.offset,
          ),
        ),
        ScrollConfiguration(
          behavior: _scrollBehavior,
          child: widget.child,
        ),
      ],
    );
  }
}
