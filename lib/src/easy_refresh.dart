part of easyrefresh;

/// EasyRefresh needs to share data
class EasyRefreshData {
  /// Header status data and responsive
  final HeaderNotifier headerNotifier;

  /// Footer status data and responsive
  final FooterNotifier footerNotifier;

  /// Whether the user scrolls and responsive
  final ValueNotifier<bool> userOffsetNotifier;

  const EasyRefreshData({
    required this.headerNotifier,
    required this.footerNotifier,
    required this.userOffsetNotifier,
  });
}

class _InheritedEasyRefresh extends InheritedWidget {
  final EasyRefreshData data;

  const _InheritedEasyRefresh({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(covariant _InheritedEasyRefresh oldWidget) =>
      data != oldWidget.data;
}

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

  static EasyRefreshData of(BuildContext context) {
    final inheritedEasyRefresh =
        context.dependOnInheritedWidgetOfExactType<_InheritedEasyRefresh>();
    assert(inheritedEasyRefresh != null,
        'Please use it in the scope of EasyRefresh!');
    return inheritedEasyRefresh!.data;
  }
}

class _EasyRefreshState extends State<EasyRefresh>
    with TickerProviderStateMixin {
  /// 滚动行为
  late ERScrollBehavior _scrollBehavior;

  /// Needs to share data
  late EasyRefreshData _data;

  /// 用户偏移通知器(记录是否为用户滚动)
  ValueNotifier<bool> get _userOffsetNotifier => _data.userOffsetNotifier;

  /// Header通知器
  HeaderNotifier get _headerNotifier => _data.headerNotifier;

  /// Footer通知器
  FooterNotifier get _footerNotifier => _data.footerNotifier;

  /// 更新中
  bool _refreshing = false;

  /// 加载中
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initData();
    // Future(() {
    //   print(PrimaryScrollController.of(context)!.position.extentInside);
    //   // PrimaryScrollController.of(context)!.addListener(() {
    //   //   print(PrimaryScrollController.of(context)!.position.pixels);
    //   // });
    // });
    _headerNotifier.addListener(() {
      // 执行刷新任务
      if (_headerNotifier._mode == IndicatorMode.processing) {
        if (!_refreshing) {
          _refreshing = true;
          Future.sync(widget.onRefresh!).whenComplete(() {
            _refreshing = false;
            _headerNotifier._setMode(IndicatorMode.processed);
          });
        }
      }
    });
    _footerNotifier.addListener(() {
      // 执行加载任务
      if (_footerNotifier._mode == IndicatorMode.processing) {
        if (!_loading) {
          _loading = true;
          Future.sync(widget.onLoad!).whenComplete(() {
            _loading = false;
            _footerNotifier._setMode(IndicatorMode.processed);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userOffsetNotifier.dispose();
  }

  /// Should be reinitialized [EasyRefreshData] when parameters change
  void _initData() {
    final userOffsetNotifier = ValueNotifier<bool>(false);
    _data = EasyRefreshData(
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: HeaderNotifier(
        triggerOffset: 70,
        clamping: false,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        safeArea: true,
      ),
      footerNotifier: FooterNotifier(
        triggerOffset: 70,
        clamping: false,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        safeArea: true,
        infiniteOffset: 100,
      ),
    );
    _scrollBehavior = ERScrollBehavior(ERScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
    ));
  }

  /// 构建Header容器
  Widget _buildHeaderView() {
    // 设置安全偏移量
    _headerNotifier._safeOffset = MediaQuery.of(context).padding.top;
    return ValueListenableBuilder(
      valueListenable: _headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        // 方向
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // 设置安全偏移量
        if (_headerNotifier._safeOffset == null) {
          final safePadding = MediaQuery.of(context).padding;
          _footerNotifier._safeOffset = axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? safePadding.top
                  : safePadding.bottom
              : axisDirection == AxisDirection.right
                  ? safePadding.left
                  : safePadding.right;
        }
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
            width: axis == Axis.vertical
                ? double.infinity
                : _headerNotifier._offset,
            height: axis == Axis.vertical
                ? _headerNotifier._offset
                : double.infinity,
          ),
        );
      },
    );
  }

  /// 构建Footer容器
  Widget _buildFooterView() {
    return ValueListenableBuilder(
      valueListenable: _footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        // physics未初始化完成
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        // 方向
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // 设置安全偏移量
        if (_footerNotifier._safeOffset == null) {
          final safePadding = MediaQuery.of(context).padding;
          _footerNotifier._safeOffset = axis == Axis.vertical
              ? axisDirection == AxisDirection.down
                  ? safePadding.bottom
                  : safePadding.top
              : axisDirection == AxisDirection.right
                  ? safePadding.right
                  : safePadding.left;
        }
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
            width: axis == Axis.vertical
                ? double.infinity
                : _footerNotifier._offset,
            height: axis == Axis.vertical
                ? _footerNotifier._offset
                : double.infinity,
          ),
        );
      },
    );
  }

  /// 构建子组件
  Widget _buildChild() {
    Widget child = ScrollConfiguration(
      behavior: _scrollBehavior,
      child: widget.child,
    );
    return _InheritedEasyRefresh(
      data: _data,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildChild(),
        // _buildHeaderView(),
        // _buildFooterView(),
      ],
    );
  }
}