import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyrefresh/src/footer/load_indicator.dart';
import 'package:flutter_easyrefresh/src/header/refresh_indicator.dart';
import 'package:flutter_easyrefresh/src/widget/empty_widget.dart';
import 'footer/footer.dart';
import 'header/header.dart';
import 'listener/scroll_notification_listener.dart';
import 'physics/scroll_physics.dart';

/// 子组件构造器
typedef EasyRefreshChildBuilder = Widget Function(
    BuildContext context, ScrollPhysics physics, Widget header, Widget footer);

/// EasyRefresh
/// 下拉刷新,上拉加载组件
class EasyRefresh extends StatefulWidget {
  /// 控制器
  final EasyRefreshController controller;

  /// 刷新回调(null为不开启刷新)
  final OnRefreshCallback onRefresh;

  /// 加载回调(null为不开启加载)
  final OnLoadCallback onLoad;

  /// 是否开启控制结束刷新
  final bool enableControlFinishRefresh;

  /// 是否开启控制结束加载
  final bool enableControlFinishLoad;

  /// 任务独立(刷新和加载状态独立)
  final bool taskIndependence;

  /// Header
  final Header header;
  final int headerIndex;

  /// Footer
  final Footer footer;

  /// 子组件构造器
  final EasyRefreshChildBuilder builder;

  /// 子组件
  final Widget child;

  /// 首次刷新
  final bool firstRefresh;

  /// 首次刷新组件
  /// 不设置时使用header
  final Widget firstRefreshWidget;

  /// 空视图
  /// 当不为null时,只会显示空视图
  /// 保留[headerIndex]以上的内容
  final Widget emptyWidget;

  /// 顶部回弹(onRefresh为null时生效)
  final bool topBouncing;

  /// 底部回弹(onLoad为null时生效)
  final bool bottomBouncing;

  /// Slivers集合
  final List<Widget> slivers;

  /// 列表方向
  final Axis scrollDirection;

  /// 反向
  final bool reverse;
  final ScrollController scrollController;
  final bool primary;
  final bool shrinkWrap;
  final Key center;
  final double anchor;
  final double cacheExtent;
  final int semanticChildCount;
  final DragStartBehavior dragStartBehavior;

  /// 全局默认Header
  static Header _defaultHeader = ClassicalHeader();
  static set defaultHeader(Header header) {
    if (header != null) {
      _defaultHeader = header;
    }
  }

  /// 全局默认Footer
  static Footer _defaultFooter = ClassicalFooter();
  static set defaultFooter(Footer footer) {
    if (footer != null) {
      _defaultFooter = footer;
    }
  }

  /// 触发时超过距离
  static double callOverExtent = 30.0;

  /// 默认构造器
  /// 将child转换为CustomScrollView可用的slivers
  EasyRefresh({
    key,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.taskIndependence = false,
    this.scrollController,
    this.header,
    this.footer,
    this.firstRefresh,
    this.firstRefreshWidget,
    this.headerIndex,
    this.emptyWidget,
    this.topBouncing = true,
    this.bottomBouncing = true,
    @required this.child,
  })  : this.scrollDirection = null,
        this.reverse = null,
        this.builder = null,
        this.primary = null,
        this.shrinkWrap = null,
        this.center = null,
        this.anchor = null,
        this.cacheExtent = null,
        this.slivers = null,
        this.semanticChildCount = null,
        this.dragStartBehavior = null;

  /// custom构造器(推荐)
  /// 直接使用CustomScrollView可用的slivers
  EasyRefresh.custom({
    key,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.taskIndependence = false,
    this.header,
    this.headerIndex,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.shrinkWrap = false,
    this.center,
    this.anchor = 0.0,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.firstRefresh,
    this.firstRefreshWidget,
    this.emptyWidget,
    this.topBouncing = true,
    this.bottomBouncing = true,
    @required this.slivers,
  })  : this.builder = null,
        this.child = null;

  /// 自定义构造器
  /// 用法灵活,但需将physics、header和footer放入列表中
  EasyRefresh.builder({
    key,
    this.controller,
    this.onRefresh,
    this.onLoad,
    this.enableControlFinishRefresh = false,
    this.enableControlFinishLoad = false,
    this.taskIndependence = false,
    this.scrollController,
    this.header,
    this.footer,
    this.firstRefresh,
    this.topBouncing = true,
    this.bottomBouncing = true,
    @required this.builder,
  })  : this.scrollDirection = null,
        this.reverse = null,
        this.child = null,
        this.primary = null,
        this.shrinkWrap = null,
        this.center = null,
        this.anchor = null,
        this.cacheExtent = null,
        this.slivers = null,
        this.semanticChildCount = null,
        this.dragStartBehavior = null,
        this.headerIndex = null,
        this.firstRefreshWidget = null,
        this.emptyWidget = null;

  @override
  _EasyRefreshState createState() {
    return _EasyRefreshState();
  }
}

class _EasyRefreshState extends State<EasyRefresh> {
  // Physics
  EasyRefreshPhysics _physics;
  // Header
  Header get _header {
    if (_enableFirstRefresh && widget.firstRefreshWidget != null)
      return _firstRefreshHeader;
    return widget.header ?? EasyRefresh._defaultHeader;
  }

  // 是否开启首次刷新
  bool _enableFirstRefresh = false;
  // 首次刷新组件
  Header _firstRefreshHeader;
  // Footer
  Footer get _footer {
    return widget.footer ?? EasyRefresh._defaultFooter;
  }

  // 子组件的ScrollController
  ScrollController _childScrollController;

  // ScrollController
  ScrollController get _scrollerController {
    return widget.scrollController ??
        _childScrollController ??
        PrimaryScrollController.of(context);
  }

  // 滚动焦点状态
  ValueNotifier<bool> _focusNotifier;
  // 任务状态
  ValueNotifier<TaskState> _taskNotifier;
  // 触发刷新状态
  ValueNotifier<bool> _callRefreshNotifier;
  // 触发加载状态
  ValueNotifier<bool> _callLoadNotifier;

  // 初始化
  @override
  void initState() {
    super.initState();
    _focusNotifier = ValueNotifier<bool>(false);
    _taskNotifier = ValueNotifier(TaskState());
    _callRefreshNotifier = ValueNotifier<bool>(false);
    _callLoadNotifier = ValueNotifier<bool>(false);
    _taskNotifier.addListener(() {
      // 监听首次刷新是否结束
      if (_enableFirstRefresh && !_taskNotifier.value.refreshing) {
        _scrollerController.jumpTo(0.0);
        setState(() {
          _enableFirstRefresh = false;
        });
      }
    });
    // 判断是否开启首次刷新
    _enableFirstRefresh = widget.firstRefresh ?? false;
    if (_enableFirstRefresh) {
      _firstRefreshHeader = FirstRefreshHeader(widget.firstRefreshWidget);
      SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
        callRefresh();
      });
    }
  }

  // 更新依赖
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 绑定控制器
    if (widget.controller != null)
      widget.controller._bindEasyRefreshState(this);
    // 列表物理形式
    _physics = EasyRefreshPhysics(
      topBouncing: widget.onRefresh == null ? widget.topBouncing : true,
      bottomBouncing: widget.onLoad == null ? widget.bottomBouncing : true,
    );
  }

  // 销毁
  void dispose() {
    super.dispose();
    _focusNotifier.dispose();
    _taskNotifier.dispose();
    _callRefreshNotifier.dispose();
    _callLoadNotifier.dispose();
  }

  // 触发刷新
  void callRefresh({Duration duration = const Duration(milliseconds: 300)}) {
    // ignore: invalid_use_of_protected_member
    if (_scrollerController == null || _scrollerController.positions.isEmpty)
      return;
    _callRefreshNotifier.value = true;
    _scrollerController
        .animateTo(0.0, duration: duration, curve: Curves.linear)
        .whenComplete(() {
      _scrollerController.animateTo(
          -(_header.triggerDistance + EasyRefresh.callOverExtent),
          duration: Duration(milliseconds: 100),
          curve: Curves.linear);
    });
  }

  // 触发加载
  void callLoad({Duration duration = const Duration(milliseconds: 300)}) {
    // ignore: invalid_use_of_protected_member
    if (_scrollerController == null || _scrollerController.positions.isEmpty)
      return;
    _callLoadNotifier.value = true;
    _scrollerController
        .animateTo(_scrollerController.position.maxScrollExtent,
            duration: duration, curve: Curves.linear)
        .whenComplete(() {
      _scrollerController.animateTo(
          _scrollerController.position.maxScrollExtent +
              _footer.triggerDistance +
              EasyRefresh.callOverExtent,
          duration: Duration(milliseconds: 100),
          curve: Curves.linear);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 列表物理形式
    bool topBouncing = widget.onRefresh == null ? widget.topBouncing : true;
    bool bottomBouncing = widget.onLoad == null ? widget.bottomBouncing : true;
    if (topBouncing != _physics.topBouncing ||
        bottomBouncing != _physics.bottomBouncing) {
      _physics = EasyRefreshPhysics(
        topBouncing: topBouncing,
        bottomBouncing: bottomBouncing,
      );
    }
    // 构建Header和Footer
    var header = widget.onRefresh == null
        ? null
        : _header.builder(context, widget, _focusNotifier, _taskNotifier,
            _callRefreshNotifier);
    var footer = widget.onLoad == null
        ? null
        : _footer.builder(
            context, widget, _focusNotifier, _taskNotifier, _callLoadNotifier);
    // 生成slivers
    List<Widget> slivers;
    if (widget.builder == null) {
      if (widget.slivers != null)
        slivers = List.from(
          widget.slivers,
          growable: true,
        );
      else if (widget.child != null) slivers = _buildSliversByChild();
      // 判断是否有空视图
      if (widget.emptyWidget != null && slivers != null) {
        slivers = slivers.sublist(0, widget.headerIndex ?? 0);
        // 添加空元素避免异常
        slivers.add(SliverList(
          delegate: SliverChildListDelegate([SizedBox()]),
        ));
        slivers.add(EmptyWidget(
          child: widget.emptyWidget,
        ));
      }
      // 插入Header和Footer
      if (header != null && slivers != null)
        slivers.insert(widget.headerIndex ?? 0, header);
      if (footer != null && slivers != null) slivers.add(footer);
    }
    // 构建列表组件
    Widget listBody;
    if (widget.builder != null) {
      listBody = widget.builder(context, _physics, header, footer);
    } else if (widget.slivers != null) {
      listBody = CustomScrollView(
        physics: _physics,
        slivers: slivers,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        controller: widget.scrollController,
        primary: widget.primary,
        shrinkWrap: widget.shrinkWrap,
        center: widget.center,
        anchor: widget.anchor,
        cacheExtent: widget.cacheExtent,
        semanticChildCount: widget.semanticChildCount,
        dragStartBehavior: widget.dragStartBehavior,
      );
    } else if (widget.child != null) {
      listBody = _buildListBodyByChild(slivers, header, footer);
    } else {
      listBody = Container();
    }
    return ScrollNotificationListener(
      onNotification: (notification) {
        return false;
      },
      onFocus: (focus) {
        _focusNotifier.value = focus;
      },
      child: listBody,
    );
  }

  // 将child转换为CustomScrollView可用的slivers
  List<Widget> _buildSliversByChild() {
    Widget child = widget.child;
    List<Widget> slivers;
    if (child == null) return slivers;
    if (child is ScrollView) {
      if (child is BoxScrollView) {
        // ignore: invalid_use_of_protected_member
        Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding)];
        } else {
          slivers = [sliver];
        }
      } else {
        // ignore: invalid_use_of_protected_member
        slivers = List.from(child.buildSlivers(context), growable: true);
      }
    } else if (child is SingleChildScrollView) {
      slivers = [
        SliverPadding(
          sliver: SliverList(
            delegate: SliverChildListDelegate([child.child]),
          ),
          padding: child.padding ?? EdgeInsets.all(0.0),
        ),
      ];
    } else if (child is! Scrollable) {
      slivers = [
        SliverToBoxAdapter(
          child: child,
        )
      ];
    }
    return slivers;
  }

  // 通过child构建列表组件
  Widget _buildListBodyByChild(
      List<Widget> slivers, Widget header, Widget footer) {
    Widget child = widget.child;
    if (child is ScrollView) {
      _childScrollController = child.controller;
      return CustomScrollView(
        physics: _physics,
        controller: child.controller ?? widget.scrollController,
        cacheExtent: child.cacheExtent,
        key: child.key,
        scrollDirection: child.scrollDirection,
        semanticChildCount: child.semanticChildCount,
        slivers: slivers,
        dragStartBehavior: child.dragStartBehavior,
        reverse: child.reverse,
      );
    } else if (child is SingleChildScrollView) {
      _childScrollController = child.controller;
      return CustomScrollView(
        physics: _physics,
        controller: child.controller ?? widget.scrollController,
        scrollDirection: child.scrollDirection,
        slivers: slivers,
        dragStartBehavior: child.dragStartBehavior,
        reverse: child.reverse,
      );
    } else if (child is Scrollable) {
      _childScrollController = child.controller;
      return Scrollable(
        physics: _physics,
        controller: child.controller ?? widget.scrollController,
        axisDirection: child.axisDirection,
        semanticChildCount: child.semanticChildCount,
        dragStartBehavior: child.dragStartBehavior,
        viewportBuilder: (context, position) {
          Viewport viewport = child.viewportBuilder(context, position);
          // 判断是否有空视图
          if (widget.emptyWidget != null) {
            if (viewport.children.length > (widget.headerIndex ?? 0) + 1) {
              viewport.children.removeRange(
                  widget.headerIndex, viewport.children.length - 1);
            }
            // 添加空元素避免异常
            viewport.children.add(SliverList(
              delegate: SliverChildListDelegate([SizedBox()]),
            ));
            viewport.children.add(EmptyWidget(
              child: widget.emptyWidget,
            ));
          }
          if (header != null) {
            viewport.children.insert(widget.headerIndex ?? 0, header);
          }
          if (footer != null) {
            viewport.children.add(footer);
          }
          return viewport;
        },
      );
    } else {
      return CustomScrollView(
        physics: _physics,
        controller: widget.scrollController,
        slivers: slivers,
      );
    }
  }
}

/// 任务状态
class TaskState {
  bool refreshing;
  bool loading;

  TaskState({this.refreshing = false, this.loading = false});

  TaskState copy({bool refreshing, bool loading}) {
    return TaskState(
      refreshing: refreshing ?? this.refreshing,
      loading: loading ?? this.loading,
    );
  }
}

/// EasyRefresh控制器
class EasyRefreshController {
  /// 触发刷新
  void callRefresh({Duration duration = const Duration(milliseconds: 300)}) {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callRefresh(duration: duration);
    }
  }

  /// 触发加载
  void callLoad({Duration duration = const Duration(milliseconds: 300)}) {
    if (this._easyRefreshState != null) {
      this._easyRefreshState.callLoad(duration: duration);
    }
  }

  /// 完成刷新
  FinishRefresh finishRefreshCallBack;
  void finishRefresh({
    bool success,
    bool noMore,
  }) {
    if (finishRefreshCallBack != null) {
      finishRefreshCallBack(success: success, noMore: noMore);
    }
  }

  /// 完成加载
  FinishLoad finishLoadCallBack;
  void finishLoad({
    bool success,
    bool noMore,
  }) {
    if (finishLoadCallBack != null) {
      finishLoadCallBack(success: success, noMore: noMore);
    }
  }

  /// 恢复刷新状态(用于没有更多后)
  VoidCallback resetRefreshStateCallBack;
  void resetRefreshState() {
    if (resetRefreshStateCallBack != null) {
      resetRefreshStateCallBack();
    }
  }

  /// 恢复加载状态(用于没有更多后)
  VoidCallback resetLoadStateCallBack;
  void resetLoadState() {
    if (resetLoadStateCallBack != null) {
      resetLoadStateCallBack();
    }
  }

  // 状态
  _EasyRefreshState _easyRefreshState;

  // 绑定状态
  void _bindEasyRefreshState(_EasyRefreshState state) {
    this._easyRefreshState = state;
  }

  void dispose() {
    this._easyRefreshState = null;
    this.finishRefreshCallBack = null;
    this.finishLoadCallBack = null;
    this.resetLoadStateCallBack = null;
    this.resetRefreshStateCallBack = null;
  }
}
