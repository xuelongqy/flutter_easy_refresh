import 'dart:async';
import 'package:flutter/material.dart';

import 'footer/footer.dart';
import 'header/header.dart';
import 'physics/scroll_physics.dart';

/// 需要刷新组件构建器
/// context为上下文[BuildContext]
/// scrollController为列表滚动控制器[ScrollController]
/// physics为列表滚动形式[ScrollPhysics]
typedef RefreshWidgetBuilder = Widget Function(
    BuildContext context,
    HeaderState header,
    FooterState footer,
    ScrollController scrollController,
    ScrollPhysics physics);

/// 回调
typedef RefreshCallback = Future<void> Function();

/// 通用刷新组件子组件构造器
/// context为上下文[BuildContext]
/// scrollController为列表滚动控制器[ScrollController]
/// physics为列表滚动形式[ScrollPhysics]
typedef CustomRefreshChildBuilder = Widget Function(
    BuildContext context,
    ScrollController scrollController,
    ScrollPhysics physics);

/// 通用的刷新组件构造器
/// context为上下文[BuildContext]
class CustomRefreshWidgetBuilder {
  // 子组件构造器
  final CustomRefreshChildBuilder childBuilder;

  CustomRefreshWidgetBuilder({
    this.childBuilder,
  }){
    assert(this.childBuilder != null);
  }

  /*Widget builder(
      BuildContext context,
      HeaderState header,
      FooterState footer,
      ScrollController scrollController,
      ScrollPhysics physics) {
    // 重新生成列表项
    List<Widget> slivers;
    // 列表内边距
    EdgeInsets listPadding;
    // 列表属性
    double cacheExtent;
    Key key;
    Key center;
    double anchor;
    int semanticChildCount;
    bool reverse;
    if (child is BoxScrollView) {
      listPadding = (child as BoxScrollView).padding;
      if (listPadding != null) {
        // ignore: invalid_use_of_protected_member
        Widget sliver = (child as BoxScrollView).buildChildLayout(context);
        slivers = [SliverPadding(padding: listPadding, sliver: sliver,)];
      } else {
        slivers = (child as BoxScrollView).buildSlivers(context);
      }
      cacheExtent = (child as BoxScrollView).cacheExtent;
      key = (child as BoxScrollView).key;
      anchor = (child as BoxScrollView).anchor;
      semanticChildCount = (child as BoxScrollView).semanticChildCount;
      reverse = (child as BoxScrollView).reverse;
    } else if (child is ScrollView) {
      // ignore: invalid_use_of_protected_member
      slivers = (child as ScrollView).buildSlivers(context);
      cacheExtent = (child as ScrollView).cacheExtent;
      key = (child as ScrollView).key;
      anchor = (child as ScrollView).anchor;
      semanticChildCount = (child as ScrollView).semanticChildCount;
      reverse = (child as ScrollView).reverse;
    } else if (child is SingleChildScrollView) {
      listPadding = (child as SingleChildScrollView).padding;
      if (listPadding != null) {
        slivers = [SliverPadding(padding: listPadding,
          sliver: (child as SingleChildScrollView).child,)];
      } else {
        slivers = [(child as SingleChildScrollView).child];
      }
      key = (child as SingleChildScrollView).key;
      reverse = (child as SingleChildScrollView).reverse;
    } else {
      slivers = [child];
    }
    // 添加非浮动Header和Footer
    /*if (!header.float && header.widget != null) {
      slivers.insert(0, SliverList(
          delegate: SliverChildListDelegate([
            Container(
              alignment: Alignment.bottomCenter,
              height: header.extent,
              width: double.infinity,
              child: footer.widget,
            )
          ])));
    }
    if (!footer.float && footer.widget != null) {
      slivers.add(SliverList(
          delegate: SliverChildListDelegate([
            Container(
              alignment: Alignment.topCenter,
              height: footer.extent,
              width: double.infinity,
              child: footer.widget,
            )
          ])));
    }*/
    return Stack(
      children: <Widget>[
        CustomScrollView(
          physics: physics,
          controller: scrollController,
          cacheExtent: cacheExtent,
          key: key,
          center: center,
          anchor: anchor,
          semanticChildCount: semanticChildCount,
          slivers: slivers,
          reverse: reverse,
        ),
        // 浮动Header
        Align(
          alignment: Alignment.topCenter,
          child: Offstage(
            offstage: !header.float && header.widget != null,
            child: header.widget ?? Container(),
          ),
        ),
        // 浮动Footer
        Align(
          alignment: Alignment.bottomCenter,
          child: Offstage(
            offstage: !footer.float && footer.widget != null,
            child: footer.widget ?? Container(),
          )
        ),
      ],
    );
  }*/

  Widget builder(
      BuildContext context,
      HeaderState header,
      FooterState footer,
      ScrollController scrollController,
      ScrollPhysics physics) {
    return Stack(
      children: <Widget>[
        childBuilder(context, scrollController, physics),
        // Header
        Align(
          alignment: Alignment.topCenter,
          child: header.widget ?? Container(),
        ),
        // Footer
        Align(
          alignment: Alignment.bottomCenter,
          child: footer.widget ?? Container(),
        ),
      ],
    );
  }
}

/// EasyRefresh
/// 下拉刷新,上拉加载组件
class EasyRefresh extends StatefulWidget {
  // EasyRefresh控制器
  final EasyRefreshController controller;
  // 滚动控制器
  final ScrollController scrollController;
  // 刷新组件构建器
  final RefreshWidgetBuilder builder;
  // 刷新回调(null为不开启刷新)
  final RefreshCallback onRefresh;
  // 加载回调(null为不开启加载)
  final RefreshCallback onLoadMore;
  // Header
  final Header header;
  // Footer
  final Footer footer;
  // 无限加载触发偏移量
  // (以列表最后一项为准[不包含Footer],null为不使用无限加载)
  final double infiniteOffset = 0.0;

  // 全局默认Header
  static Header _defaultHeader = ClassicalHeader();
  static set defaultHeader(Header header) {
    if (header != null) {
      _defaultHeader = header;
    }
  }
  // 全局默认Footer
  static Footer _defaultFooter = ClassicalFooter();
  static set defaultFooter(Footer footer) {
    if (footer != null) {
      defaultFooter = footer;
    }
  }

  EasyRefresh({
    key,
    this.controller,
    this.scrollController,
    this.builder,
    this.onRefresh,
    this.onLoadMore,
    this.header,
    this.footer
  });

  @override
  _EasyRefreshState createState() {
    return _EasyRefreshState();
  }
}

class _EasyRefreshState extends State<EasyRefresh> {

  // 滚动形式
  ScrollPhysics _scrollPhysics;

  // 初始化
  @override
  void initState() {
     super.initState();
  }

  @override
  void didChangeDependencies() {
    // 绑定EasyRefresh控制器
    if (widget.controller != null) {
      widget.controller.bindEasyRefreshState(this);
    }
    // 获取滚动控制器
    if (widget.controller != null) {
      widget.controller.scrollController = widget.scrollController ??
          widget.controller.scrollController ?? ScrollController();
    }
    // 设置Header和Footer属性
    if (widget.header == null) {
      widget.controller.header.triggerHeight = EasyRefresh._defaultHeader.triggerHeight;
      widget.controller.header.float = EasyRefresh._defaultHeader.float;
      widget.controller.header.extent = EasyRefresh._defaultHeader.extent;
    } else {
      widget.controller.header.triggerHeight = widget.header.triggerHeight;
      widget.controller.header.float = widget.header.float;
      widget.controller.header.extent = widget.header.extent;
    }
    if (widget.footer == null) {
      widget.controller.footer.triggerHeight = EasyRefresh._defaultFooter.triggerHeight;
      widget.controller.footer.float = EasyRefresh._defaultFooter.float;
      widget.controller.footer.extent = EasyRefresh._defaultFooter.extent;
    } else {
      widget.controller.footer.triggerHeight = widget.header.triggerHeight;
      widget.controller.footer.float = widget.header.float;
      widget.controller.footer.extent = widget.header.extent;
    }
    super.didChangeDependencies();
  }

  // 顶部超出回调
  void topOffset(bool bounce,double offset) {
    if (widget.controller.header.height == 0.0 && offset == 0.0) {
      return;
    }
    setState(() {
      if (bounce) {
        widget.controller.header.height = offset;
      }
    });
  }

  // 底部超出回调
  void bottomOffset(bool bounce,double offset) {
    if (widget.controller.footer.height == 0.0 && offset == 0.0) {
      return;
    }
    setState(() {
      if (bounce) {
        widget.controller.footer.height = offset;
      }
    });
  }

  // 触发刷新
  void callRefresh() {
    print("callRefresh");
  }

  // 触发加载
  void callLoadMore() {
    print("callLoadMore");
  }

  // 完成刷新
  void finishRefresh() {
    print("finishRefresh");
  }

  // 完成加载
  void finishLoadMore() {
    print("finishLoadMore");
  }

  @override
  Widget build(BuildContext context) {
    // 生成滚动形式
    _scrollPhysics = EasyRefreshPhysics(
      topOffset: topOffset,
      topExtent: widget.controller.header.triggerHeight,
      showTopExtent: widget.controller.header.status == HeaderStatus.refreshing,
      bottomOffset: bottomOffset,
      bottomExtent: widget.controller.footer.triggerHeight,
      showBottomExtent: widget.controller.footer.status == FooterStatus.loading,
    );
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 判断是否停止滑动动作
        if (notification is ScrollUpdateNotification &&
            notification.dragDetails == null ||
            notification is ScrollEndNotification &&
            notification.dragDetails == null) {
          // 判断是否超过刷新高度
          if (widget.controller.header.height >=
              widget.controller.header.triggerHeight &&
              widget.onRefresh != null) {
            setState(() {
              widget.controller.header.status = HeaderStatus.refreshing;
            });
            // 执行刷新
            widget.onRefresh().whenComplete(() {
              setState(() {
                widget.controller.header.status = HeaderStatus.idle;
              });
            });
          }
          // 判断是否超过加载高度
          if (widget.controller.footer.height >=
              widget.controller.footer.triggerHeight &&
              widget.onLoadMore != null) {
            setState(() {
              widget.controller.footer.status = FooterStatus.loading;
            });
            // 执行加载
            widget.onLoadMore().whenComplete(() {
              widget.controller.footer.status = FooterStatus.idle;
            });
          }
        }
      },
      child: widget.builder(context, _buildHeader(), _buildFooter(),
          widget.controller.scrollController, _scrollPhysics),
    );
  }

  // 构建Header
  HeaderState _buildHeader() {
    widget.controller.header.widget = widget.onRefresh == null
        ? null : widget.header == null
        ? EasyRefresh._defaultHeader.builder(context, widget.controller.header)
        : widget.header.builder(context, widget.controller.header);
    return widget.controller.header;
  }

  // 构建Footer
  FooterState _buildFooter() {
    widget.controller.footer.widget = widget.onRefresh == null
        ? null : widget.footer == null
        ? EasyRefresh._defaultFooter.builder(context, widget.controller.footer)
        : widget.footer.builder(context, widget.controller.footer);
    return widget.controller.footer;
  }
}

/// EasyRefresh控制器
class EasyRefreshController {
  // 状态
  _EasyRefreshState _easyRefreshState;
  // Header属性
  HeaderState header = HeaderState();
  // Footer状态
  FooterState footer = FooterState();
  // 滚动控制器
  ScrollController scrollController;

  // 绑定状态
  void bindEasyRefreshState(_EasyRefreshState state) {
    this._easyRefreshState = state;
  }

  // 触发刷新
  void callRefresh() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callRefresh();
    }
  }

  // 触发加载
  void callLoadMore() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callLoadMore();
    }
  }

  // 完成刷新
  void finishRefresh() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.finishRefresh();
    }
  }

  // 完成加载
  void finishLoadMore() {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.finishLoadMore();
    }
  }
}
