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

  /// Overscroll behavior when [onRefresh] is null.
  /// Won't build widget.
  final NotRefreshHeader? notRefreshHeader;

  /// Overscroll behavior when [onLoad] is null.
  /// Won't build widget.
  final NotLoadFooter? notLoadFooter;

  /// EasyRefresh child builder.
  /// Provide [ScrollPhysics], and use it in your [ScrollView].
  /// [ScrollPhysics] will not be scoped.
  final ERChildBuilder? childBuilder;

  /// Refresh callback.
  /// Triggered on refresh.
  /// The Header current state is [IndicatorMode.processing].
  /// More link [IndicatorNotifier.onTask].
  final FutureOr Function()? onRefresh;

  /// Load callback.
  /// Triggered on load.
  /// The Footer current state is [IndicatorMode.processing].
  /// More link [IndicatorNotifier.onTask].
  final FutureOr Function()? onLoad;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  /// Refresh and load can be performed simultaneously.
  final bool simultaneously;

  /// Is it possible to refresh after there is no more.
  final bool noMoreRefresh;

  /// Is it loadable after no more.
  final bool noMoreLoad;

  /// Default header indicator.
  static Header defaultHeader = BuilderHeader(
    triggerOffset: 70,
    clamping: false,
    safeArea: true,
    position: IndicatorPosition.locator,
    builder: (ctx, state) {
      Color color = Colors.blue;
      if (state.result == IndicatorResult.failed) {
        color = Colors.red;
      } else if (state.result == IndicatorResult.noMore) {
        color = Colors.yellow;
      }
      return Container(
        color: color,
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
      Color color = Colors.blue;
      if (state.result == IndicatorResult.failed) {
        color = Colors.red;
      } else if (state.result == IndicatorResult.noMore) {
        color = Colors.yellow;
      }
      return Container(
        color: color,
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
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.noMoreRefresh = false,
    this.noMoreLoad = false,
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
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.noMoreRefresh = false,
    this.noMoreLoad = false,
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

  /// Use [EasyRefresh.defaultHeader] without [EasyRefresh.header].
  /// Use [NotRefreshHeader] when [EasyRefresh.onRefresh] is null.
  Header get _header {
    if (widget.onRefresh == null) {
      if (widget.notRefreshHeader != null) {
        return widget.notRefreshHeader!;
      } else {
        final h = widget.header ?? EasyRefresh.defaultHeader;
        return NotRefreshHeader(
          clamping: h.clamping,
          spring: h.spring,
        );
      }
    } else {
      return widget.header ?? EasyRefresh.defaultHeader;
    }
  }

  /// Use [EasyRefresh.defaultFooter] without [EasyRefresh.footer].
  /// Use [NotLoadFooter] when [EasyRefresh.onLoad] is null.
  Footer get _footer {
    if (widget.onLoad == null) {
      if (widget.notLoadFooter != null) {
        return widget.notLoadFooter!;
      } else {
        final f = widget.footer ?? EasyRefresh.defaultFooter;
        return NotLoadFooter(
          clamping: f.clamping,
          spring: f.spring,
        );
      }
    } else {
      return widget.footer ?? EasyRefresh.defaultFooter;
    }
  }

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
  }

  @override
  void didUpdateWidget(covariant EasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update header and footer.
    if (oldWidget.header != widget.header ||
        oldWidget.noMoreRefresh != widget.noMoreRefresh) {
      _headerNotifier._update(
        indicator: _header,
        noMoreProcess: widget.noMoreRefresh,
      );
    }
    if (oldWidget.footer != widget.footer ||
        oldWidget.noMoreLoad != widget.noMoreLoad) {
      _footerNotifier._update(
        indicator: _footer,
        noMoreProcess: widget.noMoreLoad,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _headerNotifier.dispose();
    _footerNotifier.dispose();
    _userOffsetNotifier.dispose();
  }

  /// Initialize [EasyRefreshData].
  void _initData() {
    final userOffsetNotifier = ValueNotifier<bool>(false);
    _data = EasyRefreshData(
      userOffsetNotifier: userOffsetNotifier,
      headerNotifier: HeaderNotifier(
        header: _header,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        onRefresh: widget.onRefresh,
        noMoreRefresh: widget.noMoreRefresh,
        onCanRefresh: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_footerNotifier._processing;
          }
        },
      ),
      footerNotifier: FooterNotifier(
        footer: _footer,
        userOffsetNotifier: userOffsetNotifier,
        vsync: this,
        onLoad: widget.onLoad,
        noMoreLoad: widget.noMoreLoad,
        onCanLoad: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_headerNotifier._processing;
          }
        },
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

  /// Build Header widget.
  /// When the Header [Indicator.position] is
  /// [IndicatorPosition.above] or [IndicatorPosition.above].
  Widget _buildHeaderView() {
    return ValueListenableBuilder(
      valueListenable: _headerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        // Physics is not initialized.
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        // Axis and direction.
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // Set safe area offset.
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

  /// Build Footer widget.
  /// When the Footer [Indicator.position] is
  /// [IndicatorPosition.above] or [IndicatorPosition.above].
  Widget _buildFooterView() {
    return ValueListenableBuilder(
      valueListenable: _footerNotifier.listenable(),
      builder: (ctx, notifier, _) {
        // Physics is not initialized.
        if (_headerNotifier.axis == null ||
            _headerNotifier.axisDirection == null) {
          return const SizedBox();
        }
        // Axis and direction.
        final axis = _headerNotifier.axis!;
        final axisDirection = _headerNotifier.axisDirection!;
        // Set safe area offset.
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
