part of easyrefresh;

/// EasyRefresh child builder.
/// Provide [ScrollPhysics], and use it in your [ScrollView].
/// [ScrollPhysics] will not be scoped.
typedef ERChildBuilder = Widget Function(
    BuildContext context, ScrollPhysics physics);

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
  /// Try to avoid including multiple ScrollViews.
  /// Or set separate ScrollPhysics for other ScrollView.
  /// Otherwise use [EasyRefresh.builder].
  final Widget? child;

  /// EasyRefresh child builder.
  /// Provide [ScrollPhysics], and use it in your [ScrollView].
  /// [ScrollPhysics] will not be scoped.
  final ERChildBuilder? childBuilder;

  /// 刷新回调
  final FutureOr Function()? onRefresh;

  /// 加载回调
  final FutureOr Function()? onLoad;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  const EasyRefresh({
    Key? key,
    required this.child,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
  })  : childBuilder = null,
        super(key: key);

  const EasyRefresh.builder({
    Key? key,
    required this.childBuilder,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
  })  : child = null,
        super(key: key);

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
  /// [ScrollPhysics] use it in EasyRefresh.
  late _ERScrollPhysics _physics;

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
        header: BuilderHeader(
          triggerOffset: 70,
          clamping: false,
          safeArea: true,
          useLocator: true,
          builder: (ctx, state) {
            return Container(
              color: Colors.blue,
              width:
                  state.axis == Axis.vertical ? double.infinity : state.offset,
              height:
                  state.axis == Axis.vertical ? state.offset : double.infinity,
            );
          },
        ),
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
      ),
      footerNotifier: FooterNotifier(
        footer: BuilderFooter(
          triggerOffset: 70,
          clamping: false,
          safeArea: true,
          infiniteOffset: 100,
          useLocator: true,
          builder: (ctx, state) {
            return Container(
              color: Colors.blue,
              width:
                  state.axis == Axis.vertical ? double.infinity : state.offset,
              height:
                  state.axis == Axis.vertical ? state.offset : double.infinity,
            );
          },
        ),
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
      ),
    );
    _physics = _ERScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
      spring: widget.spring,
      frictionFactor: widget.frictionFactor,
    );
  }

  /// 构建Header容器
  Widget _buildHeaderView() {
    assert(!_headerNotifier.useLocator,
        'When useLocator is true, you need to use HeaderLocator.');
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
          child: _headerNotifier._build(context),
        );
      },
    );
  }

  /// 构建Footer容器
  Widget _buildFooterView() {
    assert(!_footerNotifier.useLocator,
        'When useLocator is true, you need to use FooterLocator.');
    // 设置安全偏移量
    _footerNotifier._safeOffset = MediaQuery.of(context).padding.bottom;
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
          child: _footerNotifier._build(context),
        );
      },
    );
  }

  /// Build complete child widget.
  Widget _buildChild() {
    Widget child;
    if (widget.childBuilder != null) {
      child = ScrollConfiguration(
        behavior: const _ERScrollBehavior(),
        child: widget.childBuilder!(context, _physics),
      );
    } else {
      child = ScrollConfiguration(
        behavior: _ERScrollBehavior(_physics),
        child: widget.child!,
      );
    }
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
        if (!_headerNotifier.useLocator) _buildHeaderView(),
        if (!_footerNotifier.useLocator) _buildFooterView(),
      ],
    );
  }
}
