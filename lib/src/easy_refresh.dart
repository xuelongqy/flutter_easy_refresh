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

  /// Header indicator.
  final Header? header;

  /// Footer indicator.
  final Footer? footer;

  /// EasyRefresh child builder.
  /// Provide [ScrollPhysics], and use it in your [ScrollView].
  /// [ScrollPhysics] will not be scoped.
  final ERChildBuilder? childBuilder;

  /// Refresh callback.
  /// Triggered on refresh.
  /// The current state is [IndicatorMode.processing].
  final FutureOr Function()? onRefresh;

  /// Load callback.
  /// Triggered on load.
  /// The current state is [IndicatorMode.processing].
  final FutureOr Function()? onLoad;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  /// Default header indicator.
  static Header defaultHeader = BuilderHeader(
    triggerOffset: 70,
    clamping: false,
    safeArea: true,
    position: IndicatorPosition.locator,
    builder: (ctx, state) {
      return Container(
        color: Colors.blue,
        width: state.axis == Axis.vertical ? double.infinity : state.offset,
        height: state.axis == Axis.vertical ? state.offset : double.infinity,
      );
    },
  );

  /// Default footer indicator.
  static Footer defaultFooter = BuilderFooter(
    triggerOffset: 70,
    clamping: false,
    safeArea: true,
    infiniteOffset: 100,
    position: IndicatorPosition.locator,
    builder: (ctx, state) {
      return Container(
        color: Colors.blue,
        width: state.axis == Axis.vertical ? double.infinity : state.offset,
        height: state.axis == Axis.vertical ? state.offset : double.infinity,
      );
    },
  );

  const EasyRefresh({
    Key? key,
    required this.child,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
  })  : childBuilder = null,
        super(key: key);

  const EasyRefresh.builder({
    Key? key,
    required this.childBuilder,
    this.header,
    this.footer,
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

  /// Needs to share data.
  late EasyRefreshData _data;

  /// User triggered notifier.
  /// Record user triggers and releases.
  ValueNotifier<bool> get _userOffsetNotifier => _data.userOffsetNotifier;

  /// Header indicator notifier.
  HeaderNotifier get _headerNotifier => _data.headerNotifier;

  /// Footer indicator notifier.
  FooterNotifier get _footerNotifier => _data.footerNotifier;

  /// Currently refreshing.
  bool _refreshing = false;

  /// currently loading.
  bool _loading = false;

  /// Use [EasyRefresh.defaultHeader] without [EasyRefresh.header].
  Header get _header => widget.header ?? EasyRefresh.defaultHeader;

  /// Use [EasyRefresh.defaultFooter] without [EasyRefresh.footer].
  Footer get _footer => widget.footer ?? EasyRefresh.defaultFooter;

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
      // Execute refresh task.
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
      // Execute load task.
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
  void didUpdateWidget(covariant EasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update header and footer.
    if (oldWidget.header != widget.header) {
      _headerNotifier._updateIndicator(_header);
    }
    if (oldWidget.footer != widget.footer) {
      _footerNotifier._updateIndicator(_footer);
    }
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
        header: _header,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
      ),
      footerNotifier: FooterNotifier(
        footer: _footer,
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

  /// Build content widget.
  Widget _buildContent() {
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
    final contentWidget = _buildContent();
    final List<Widget> children = [];
    final hPosition = _headerNotifier.iPosition;
    final fPosition = _footerNotifier.iPosition;
    // Set safe area offset.
    final mPadding = MediaQuery.of(context).padding;
    if (hPosition != IndicatorPosition.locator) {
      _headerNotifier._safeOffset = mPadding.top;
    }
    if (fPosition != IndicatorPosition.locator) {
      _footerNotifier._safeOffset = mPadding.bottom;
    }
    // Set the position of widgets.
    if (hPosition == IndicatorPosition.above) {
      children.add(_buildHeaderView());
    }
    if (fPosition == IndicatorPosition.above) {
      children.add(_buildFooterView());
    }
    children.add(contentWidget);
    if (hPosition == IndicatorPosition.behind) {
      children.add(_buildHeaderView());
    }
    if (fPosition == IndicatorPosition.behind) {
      children.add(_buildFooterView());
    }
    if (children.length == 1) {
      return contentWidget;
    }
    return Stack(
      fit: StackFit.expand,
      children: children,
    );
  }
}
