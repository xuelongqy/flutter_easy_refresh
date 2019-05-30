import 'package:flutter/widgets.dart';

/// Footer状态枚举
enum FooterStatus { idle, start, ready, loading, completed, noMore, failed }

/// Footer构造器
typedef FooterBuilder = Widget Function(
    BuildContext context, FooterState state);

/// Footer属性
class FooterState {
  // 状态
  FooterStatus status = FooterStatus.idle;
  // 高度
  double height = 0.0;
  // Footer容器高度
  double extent;
  // 触发刷新高度
  double triggerHeight = 70.0;
  // 是否浮动
  bool float = false;
  // 组件
  Widget widget;
}

/// Header
abstract class Footer {
  // Footer容器高度
  final double extent;
  // 高度(超过这个高度出发刷新)
  final double triggerHeight;
  // 是否浮动
  final bool float;
  // 完成延时
  final Duration completeDuration;

  Footer({
    this.extent = 400.0,
    this.triggerHeight = 70.0,
    this.float = false,
    this.completeDuration = const Duration(seconds: 1),
  });

  // Header构造器
  Widget builder(BuildContext context, FooterState state);
}

/// 通用Footer构造器
class CustomFooter extends Footer {

  // Footer构造函数
  final FooterBuilder footerBuilder;

  CustomFooter({
    extent = 400.0,
    triggerHeight = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
    this.footerBuilder
  }): super(
    extent: extent,
    triggerHeight: triggerHeight,
    float: float,
    completeDuration: completeDuration
  ){
    assert(this.footerBuilder != null);
  }

  @override
  Widget builder(BuildContext context, FooterState state) {
    return this.footerBuilder(context, state);
  }
}

/// 经典Footer
class ClassicalFooter extends Footer {

  ClassicalFooter({
    extent = 400.0,
    triggerHeight = 70.0,
    float = false,
    completeDuration = const Duration(seconds: 1),
  }): super(
    extent: extent,
    triggerHeight: triggerHeight,
    float: float,
    completeDuration: completeDuration
  );

  @override
  Widget builder(BuildContext context, FooterState state) {
    return Container(
      height: 70.0,
      width: double.infinity,
      child: Center(
        child: Text('ClassicalFooter'),
      ),
    );
  }
}