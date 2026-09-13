part of '../easy_refresh.dart';

/// EasyRefresh child builder.
/// Provide [ScrollPhysics], and use it in your [ScrollView].
/// [ScrollPhysics] will not be scoped.
typedef ERChildBuilder = Widget Function(
  BuildContext context,
  ScrollPhysics physics,
);

typedef ERScrollBehaviorBuilder = ScrollBehavior Function(
  ScrollPhysics? physics,
);

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

/// EasyRefresh inherited widget.
class _InheritedEasyRefresh extends InheritedWidget {
  final EasyRefreshData data;

  const _InheritedEasyRefresh({
    // ignore: unused_element_parameter
    super.key,
    required this.data,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant _InheritedEasyRefresh oldWidget) =>
      data != oldWidget.data;
}

/// A flutter widget that provides pull-down refresh and pull-up load.
class EasyRefresh extends StatefulWidget {
  /// Try to avoid including multiple ScrollViews.
  /// Or set separate ScrollPhysics for other ScrollView.
  /// Otherwise use [EasyRefresh.builder].
  final Widget? child;

  /// EasyRefresh controller.
  final EasyRefreshController? controller;

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
  /// When null, disable refresh.
  /// The Header current state is [IndicatorMode.processing].
  /// More see [IndicatorNotifier._onTask].
  /// The return value can be [IndicatorResult],
  /// the default processing result is [IndicatorResult.success],
  /// and [IndicatorResult.fail] when an exception occurs.
  /// When [EasyRefreshController.controlFinishRefresh] is true,
  /// the return value is invalid.
  final FutureOr Function()? onRefresh;

  /// Load callback.
  /// Triggered on load.
  /// When null, disable load.
  /// The Footer current state is [IndicatorMode.processing].
  /// More see [IndicatorNotifier._onTask].
  /// The return value can be [IndicatorResult],
  /// the default processing result is [IndicatorResult.success],
  /// and [IndicatorResult.fail] when an exception occurs.
  /// When [EasyRefreshController.controlFinishLoad] is true,
  /// the return value is invalid.
  final FutureOr Function()? onLoad;

  /// Structure that describes a spring's constants.
  /// When spring is not set in [Header] and [Footer].
  final physics.SpringDescription? spring;

  /// Friction factor when list is out of bounds.
  final FrictionFactor? frictionFactor;

  /// Refresh and load can be performed simultaneously.
  final bool simultaneously;

  /// Is it possible to refresh after there is no more.
  final bool canRefreshAfterNoMore;

  /// Is it possible to load after there is no more.
  final bool canLoadAfterNoMore;

  /// Reset after refresh when no more deactivation is loaded.
  final bool resetAfterRefresh;

  /// Refresh on start.
  /// When the EasyRefresh build is complete, trigger the refresh.
  final bool refreshOnStart;

  /// Header for refresh on start.
  /// Use [header] when null.
  final Header? refreshOnStartHeader;

  /// Offset beyond trigger offset when calling refresh.
  /// Used when refreshOnStart is true and [EasyRefreshController.callRefresh].
  final double callRefreshOverOffset;

  /// Offset beyond trigger offset when calling load.
  /// Used when [EasyRefreshController.callLoad].
  final double callLoadOverOffset;

  /// See [Stack.StackFit]
  final StackFit fit;

  /// See [Stack.clipBehavior].
  final Clip clipBehavior;

  /// Use [ERScrollBehavior] by default.
  ///
  /// example:
  /// ```dart
  /// EasyRefresh(
  ///   scrollBehaviorBuilder: (ScrollPhysics? physics) {
  ///     return YourCustomScrollBehavior(physics);
  ///   }
  /// )
  /// ```
  final ERScrollBehaviorBuilder? scrollBehaviorBuilder;

  /// When the position cannot be determined, such as [NestedScrollView].
  /// Mainly used to trigger events.
  /// NOTE: You also need to bind this to your [Scrollable.controller].
  final ScrollController? scrollController;

  /// Direction of execution.
  /// Other scroll directions will not show indicators and perform task.
  final Axis? triggerAxis;

  /// Use false by default.
  /// When true, EasyRefresh uses NestedScrollView-safe physics: Header offset
  /// is tracked from the outer position at the global top, Footer from the
  /// current inner. Pass the same physics to NestedScrollView and its body.
  /// This does not mean "enable extra Nested ifs" on the default bouncing path.
  final bool isNested;

  /// Optional NestedScrollView outer [ScrollController].
  /// Used when wrapping a custom nested view (for example ExtendedNestedScrollView).
  final ScrollController? nestedOuterController;

  /// Optional NestedScrollView inner [ScrollController].
  /// When the body has multiple inners, this should be the active inner.
  final ScrollController? nestedInnerController;

  final NestedScrollViewHeaderSliversBuilder? _nestedHeaderSliverBuilder;

  final Widget? _nestedBody;

  final Axis _nestedScrollDirection;

  final bool _nestedReverse;

  final bool _nestedFloatHeaderSlivers;

  final Clip _nestedClipBehavior;

  final DragStartBehavior _nestedDragStartBehavior;

  final String? _nestedRestorationId;

  /// Default header indicator.
  static Header Function() defaultHeaderBuilder = _defaultHeaderBuilder;

  static Header _defaultHeaderBuilder() => const ClassicHeader();

  static Header get _defaultHeader => defaultHeaderBuilder.call();

  /// Default footer indicator.
  static Footer Function() defaultFooterBuilder = _defaultFooterBuilder;

  static Footer _defaultFooterBuilder() => const ClassicFooter();

  static Footer get _defaultFooter => defaultFooterBuilder.call();

  /// Default ScrollBehavior builder.
  static ScrollBehavior Function(ScrollPhysics? physics)
  defaultScrollBehaviorBuilder = _defaultScrollBehaviorBuilder;

  static ScrollBehavior _defaultScrollBehaviorBuilder(ScrollPhysics? physics) =>
      ERScrollBehavior(physics);

  const EasyRefresh({
    super.key,
    required this.child,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
    this.nestedOuterController,
    this.nestedInnerController,
  }) : childBuilder = null,
       _nestedHeaderSliverBuilder = null,
       _nestedBody = null,
       _nestedScrollDirection = Axis.vertical,
       _nestedReverse = false,
       _nestedFloatHeaderSlivers = false,
       _nestedClipBehavior = Clip.hardEdge,
       _nestedDragStartBehavior = DragStartBehavior.start,
       _nestedRestorationId = null,
       assert(
         callRefreshOverOffset > 0,
         'callRefreshOverOffset must be greater than 0.',
       ),
       assert(
         callLoadOverOffset > 0,
         'callLoadOverOffset must be greater than 0.',
       );

  const EasyRefresh.builder({
    super.key,
    required this.childBuilder,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.isNested = false,
    this.nestedOuterController,
    this.nestedInnerController,
  }) : child = null,
       _nestedHeaderSliverBuilder = null,
       _nestedBody = null,
       _nestedScrollDirection = Axis.vertical,
       _nestedReverse = false,
       _nestedFloatHeaderSlivers = false,
       _nestedClipBehavior = Clip.hardEdge,
       _nestedDragStartBehavior = DragStartBehavior.start,
       _nestedRestorationId = null,
       assert(
         callRefreshOverOffset > 0,
         'callRefreshOverOffset must be greater than 0.',
       ),
       assert(
         callLoadOverOffset > 0,
         'callLoadOverOffset must be greater than 0.',
       );

  /// First-class integration for Flutter's [NestedScrollView].
  ///
  /// Builds a [NestedScrollView], applies NestedScrollView-safe physics, and
  /// inserts a [HeaderLocator] ahead of [headerSliverBuilder] when [onRefresh]
  /// is not null. A non-clamping Header is promoted to clamping + locator.
  /// [body] does not need an explicit `physics`; this widget's
  /// [ScrollConfiguration] already carries it.
  ///
  /// Do not wrap ExtendedNestedScrollView or other custom nested views —
  /// this constructor can only create the Flutter [NestedScrollView]. Use
  /// [EasyRefresh.builder] with [isNested] `true` and assign the builder
  /// `physics` to that view instead.
  ///
  /// A Footer on this widget binds the **visible** inner (for example the
  /// current [TabBarView] tab). Independent per-tab load should use a
  /// Footer-only [EasyRefresh] inside [body] instead of [onLoad] here.
  /// When each tab owns its Header, omit [onRefresh] on this layer (physics
  /// for the nested view only) and put Header/Footer on the inner
  /// [EasyRefresh]; see the NestedScrollView sample.
  const EasyRefresh.nested({
    super.key,
    required NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
    required Widget body,
    this.controller,
    this.header,
    this.footer,
    this.onRefresh,
    this.onLoad,
    this.spring,
    this.frictionFactor,
    this.notRefreshHeader,
    this.notLoadFooter,
    this.simultaneously = false,
    this.canRefreshAfterNoMore = false,
    this.canLoadAfterNoMore = false,
    this.resetAfterRefresh = true,
    this.refreshOnStart = false,
    this.refreshOnStartHeader,
    this.callRefreshOverOffset = 20,
    this.callLoadOverOffset = 20,
    this.fit = StackFit.loose,
    this.clipBehavior = Clip.hardEdge,
    this.scrollBehaviorBuilder,
    this.scrollController,
    this.triggerAxis,
    this.nestedOuterController,
    this.nestedInnerController,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    bool floatHeaderSlivers = false,
    Clip nestedClipBehavior = Clip.hardEdge,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    String? restorationId,
  }) : child = null,
       childBuilder = null,
       isNested = true,
       _nestedHeaderSliverBuilder = headerSliverBuilder,
       _nestedBody = body,
       _nestedScrollDirection = scrollDirection,
       _nestedReverse = reverse,
       _nestedFloatHeaderSlivers = floatHeaderSlivers,
       _nestedClipBehavior = nestedClipBehavior,
       _nestedDragStartBehavior = dragStartBehavior,
       _nestedRestorationId = restorationId,
       assert(
         callRefreshOverOffset > 0,
         'callRefreshOverOffset must be greater than 0.',
       ),
       assert(
         callLoadOverOffset > 0,
         'callLoadOverOffset must be greater than 0.',
       );

  @override
  State<StatefulWidget> createState() => _EasyRefreshState();

  static EasyRefreshData of(BuildContext context) {
    final inheritedEasyRefresh = context
        .dependOnInheritedWidgetOfExactType<_InheritedEasyRefresh>();
    assert(
      inheritedEasyRefresh != null,
      'Please use it in the scope of EasyRefresh!',
    );
    return inheritedEasyRefresh!.data;
  }
}

/// EasyRefresh widget state.
class _EasyRefreshState extends State<EasyRefresh>
    with TickerProviderStateMixin {
  /// [ScrollPhysics] use it in EasyRefresh.
  late _ERScrollPhysics _physics;

  final GlobalKey<NestedScrollViewState> _nestedViewKey =
      GlobalKey<NestedScrollViewState>();

  /// Needs to share data.
  late EasyRefreshData _data;

  /// User triggered notifier.
  /// Record user triggers and releases.
  ValueNotifier<bool> get _userOffsetNotifier => _data.userOffsetNotifier;

  /// Header indicator notifier.
  HeaderNotifier get _headerNotifier => _data.headerNotifier;

  /// Footer indicator notifier.
  FooterNotifier get _footerNotifier => _data.footerNotifier;

  /// Whether the current is refresh on start.
  bool _isRefreshOnStart = false;

  /// Indicator waiting for refresh task to complete.
  bool get _waitRefreshResult =>
      !(widget.controller?.controlFinishRefresh ?? false);

  /// Indicator waiting for load task to complete.
  bool get _waitLoadResult => !(widget.controller?.controlFinishLoad ?? false);

  /// Use [EasyRefresh._defaultHeader] without [EasyRefresh.header].
  /// Use [NotRefreshHeader] when [EasyRefresh.onRefresh] is null.
  Header get _header {
    Header header;
    if (widget.onRefresh == null) {
      if (widget.notRefreshHeader != null) {
        header = widget.notRefreshHeader!;
      } else {
        final h = widget.header ?? EasyRefresh._defaultHeader;
        header = NotRefreshHeader(
          clamping: h.clamping,
          position: h.position,
          spring: h.spring,
          frictionFactor: h.frictionFactor,
          hitOver: h.hitOver,
          maxOverOffset: h.maxOverOffset,
        );
      }
    } else {
      header = widget.header ?? EasyRefresh._defaultHeader;
      if (_isRefreshOnStart) {
        header = OverrideHeader(
          header: widget.refreshOnStartHeader ?? header,
          triggerWhenReach: true,
        );
      }
      header = _nestedCompatibleHeader(header);
    }
    return header;
  }

  Header _nestedCompatibleHeader(Header header) {
    if (!widget.isNested) {
      return header;
    }
    final wantLocator = widget._nestedHeaderSliverBuilder != null;
    final needClamping = !header.clamping;
    final needLocator =
        wantLocator &&
        header.position != IndicatorPosition.locator &&
        header.position != IndicatorPosition.custom;
    if (!needClamping && !needLocator) {
      return header;
    }
    assert(() {
      debugPrint(
        'EasyRefresh.nested uses a clamping Header'
        '${needLocator ? ' with IndicatorPosition.locator' : ''}.',
      );
      return true;
    }());
    return OverrideHeader(
      header: header,
      clamping: true,
      position: needLocator ? IndicatorPosition.locator : header.position,
    );
  }

  /// Use [EasyRefresh._defaultFooter] without [EasyRefresh.footer].
  /// Use [NotLoadFooter] when [EasyRefresh.onLoad] is null.
  Footer get _footer {
    if (widget.onLoad == null) {
      if (widget.notLoadFooter != null) {
        return widget.notLoadFooter!;
      } else {
        final f = widget.footer ?? EasyRefresh._defaultFooter;
        return NotLoadFooter(
          clamping: f.clamping,
          position: f.position,
          spring: f.spring,
          frictionFactor: f.frictionFactor,
          hitOver: f.hitOver,
          maxOverOffset: f.maxOverOffset,
        );
      }
    } else {
      return widget.footer ?? EasyRefresh._defaultFooter;
    }
  }

  @override
  void initState() {
    super.initState();
    // Refresh on start.
    if (widget.refreshOnStart && widget.onRefresh != null) {
      _isRefreshOnStart = true;
      Future(() {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _callRefresh(
            overOffset: widget.callRefreshOverOffset,
            duration: null,
          );
        });
      });
    }
    _initData();
    widget.controller?._bind(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNestedHost();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNestedHost();
    });
  }

  @override
  void didUpdateWidget(covariant EasyRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isNested != widget.isNested) {
      _physics = _createPhysics();
    }
    // Recipe B inner widgets keep [isNested] false on the widget and are
    // promoted to nested physics at runtime. Preserve that adopted flag.
    final isNested = widget.isNested || _physics is _ERNestedScrollPhysics;
    _headerNotifier._update(
      indicator: _header,
      canProcessAfterNoMore: widget.canRefreshAfterNoMore,
      triggerAxis: widget.triggerAxis,
      task: _onRefresh,
      waitTaskRefresh: _waitRefreshResult,
      isNested: isNested,
    );
    _footerNotifier._update(
      indicator: _footer,
      canProcessAfterNoMore: widget.canLoadAfterNoMore,
      triggerAxis: widget.triggerAxis,
      task: widget.onLoad,
      waitTaskRefresh: _waitLoadResult,
      isNested: isNested,
    );
    // Update controller.
    if (widget.controller != null &&
        oldWidget.controller != widget.controller) {
      widget.controller?._bind(this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNestedHost();
    });
  }

  @override
  void dispose() {
    _headerNotifier.dispose();
    _footerNotifier.dispose();
    _userOffsetNotifier.dispose();
    super.dispose();
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
        onRefresh: _onRefresh,
        canProcessAfterNoMore: widget.canRefreshAfterNoMore,
        isNested: widget.isNested,
        triggerAxis: widget.triggerAxis,
        waitRefreshResult: _waitRefreshResult,
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
        canProcessAfterNoMore: widget.canLoadAfterNoMore,
        isNested: widget.isNested,
        triggerAxis: widget.triggerAxis,
        waitLoadResult: _waitLoadResult,
        onCanLoad: () {
          if (widget.simultaneously) {
            return true;
          } else {
            return !_headerNotifier._processing && !_isRefreshOnStart;
          }
        },
      ),
    );
    _physics = _createPhysics();
  }

  _ERScrollPhysics _createPhysics() {
    if (widget.isNested) {
      return _ERNestedScrollPhysics(
        userOffsetNotifier: _userOffsetNotifier,
        headerNotifier: _headerNotifier,
        footerNotifier: _footerNotifier,
        spring: widget.spring,
        frictionFactor: widget.frictionFactor,
      );
    }
    return _ERScrollPhysics(
      userOffsetNotifier: _userOffsetNotifier,
      headerNotifier: _headerNotifier,
      footerNotifier: _footerNotifier,
      spring: widget.spring,
      frictionFactor: widget.frictionFactor,
    );
  }

  NestedScrollViewState? get _nestedHostState {
    return _nestedViewKey.currentState ??
        context.findAncestorStateOfType<NestedScrollViewState>();
  }

  /// Official [NestedScrollViewState] or ExtendedNestedScrollViewState.
  /// The latter does not extend [NestedScrollViewState], but exposes the
  /// same `outerController` / `innerController` getters.
  Object? _nestedHostLike() {
    final official = _nestedHostState;
    if (official != null) {
      return official;
    }
    State? found;
    context.visitAncestorElements((element) {
      if (element is StatefulElement) {
        final name = element.state.runtimeType.toString();
        if (name.contains('NestedScrollViewState')) {
          found = element.state;
          return false;
        }
      }
      return true;
    });
    return found;
  }

  ScrollController? _nestedHostOuterController() {
    try {
      return (_nestedHostLike() as dynamic)?.outerController
          as ScrollController?;
    } catch (_) {
      return null;
    }
  }

  ScrollController? _nestedHostInnerController() {
    try {
      return (_nestedHostLike() as dynamic)?.innerController
          as ScrollController?;
    } catch (_) {
      return null;
    }
  }

  bool _hasAncestorNestedScrollView() {
    if (context.findAncestorStateOfType<NestedScrollViewState>() != null) {
      return true;
    }
    var found = false;
    context.visitAncestorElements((element) {
      final name = element.widget.runtimeType.toString();
      if (element.widget is NestedScrollView ||
          name.contains('NestedScrollView')) {
        found = true;
        return false;
      }
      return true;
    });
    return found;
  }

  void _syncNestedHost() {
    if (!mounted) {
      return;
    }
    _adoptNestedHostIfNeeded();
    _attachAncestorHeaderIfNeeded();
    _bindNestedControllers();
  }

  bool _hasDescendantNestedScrollView() {
    var found = false;
    void visit(Element element) {
      if (found) {
        return;
      }
      final typeName = element.widget.runtimeType.toString();
      if (element.widget is NestedScrollView ||
          typeName.contains('NestedScrollView')) {
        found = true;
        return;
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return found;
  }

  void _switchToNestedPhysics({
    HeaderNotifier? headerNotifier,
    bool bindHeaderPhysics = true,
  }) {
    final header = headerNotifier ?? _headerNotifier;
    _headerNotifier._isNested = true;
    _footerNotifier._isNested = true;
    _headerNotifier._ensureClampingAnimation();
    _footerNotifier._ensureClampingAnimation();
    header._isNested = true;
    header._ensureClampingAnimation();
    setState(() {
      _physics = _ERNestedScrollPhysics(
        userOffsetNotifier: _userOffsetNotifier,
        headerNotifier: header,
        footerNotifier: _footerNotifier,
        spring: widget.spring,
        frictionFactor: widget.frictionFactor,
        bindHeaderPhysics: bindHeaderPhysics,
      );
    });
  }

  /// Pattern B inner lists must drive the page Header, not a no-op
  /// [NotRefreshHeader] on this EasyRefresh.
  void _attachAncestorHeaderIfNeeded() {
    if (widget.onRefresh != null || widget.isNested) {
      return;
    }
    final inherited = context
        .getInheritedWidgetOfExactType<_InheritedEasyRefresh>();
    final host = inherited?.data.headerNotifier;
    if (host == null ||
        host._task == null ||
        identical(host, _headerNotifier)) {
      return;
    }
    if (identical(_physics.headerNotifier, host)) {
      return;
    }
    _switchToNestedPhysics(headerNotifier: host, bindHeaderPhysics: false);
  }

  /// Pattern B: an EasyRefresh inside NestedScrollView (often Footer-only)
  /// must use nested-safe physics even when [EasyRefresh.isNested] is false.
  void _adoptNestedHostIfNeeded() {
    if (widget.isNested) {
      return;
    }
    if (_physics is _ERNestedScrollPhysics) {
      _headerNotifier._isNested = true;
      _footerNotifier._isNested = true;
      _headerNotifier._ensureClampingAnimation();
      _footerNotifier._ensureClampingAnimation();
      return;
    }
    if (_hasAncestorNestedScrollView()) {
      _switchToNestedPhysics();
      return;
    }
    // Wrapping a NestedScrollView with isNested: false must stay bouncing.
    if (_hasDescendantNestedScrollView()) {
      return;
    }
    final local = _findLocalScrollPosition();
    if (local != null &&
        (local.debugLabel == 'inner' ||
            local.debugLabel == 'outer' ||
            local.runtimeType.toString().contains('NestedScrollPosition'))) {
      _switchToNestedPhysics();
    }
  }

  bool _isNestedInnerPosition(ScrollPosition position) {
    if (position.debugLabel == 'outer' || position.axis != Axis.vertical) {
      return false;
    }
    return position.debugLabel == 'inner' ||
        position.runtimeType.toString().contains('NestedScrollPosition');
  }

  /// TabBarView / IndexedStack keep every tab's inner attached. Prefer the
  /// one that is actually on screen so Footer / callLoad follow the visible tab.
  double _currentInnerScore(BuildContext context, ScrollPosition position) {
    if (!_isNestedInnerPosition(position)) {
      return double.negativeInfinity;
    }
    try {
      if (!TickerMode.valuesOf(context).enabled || !Visibility.of(context)) {
        return double.negativeInfinity;
      }
    } catch (_) {
      return double.negativeInfinity;
    }
    final offstage = context.findAncestorWidgetOfExactType<Offstage>();
    if (offstage != null && offstage.offstage) {
      return double.negativeInfinity;
    }
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        !renderObject.attached ||
        renderObject.size.isEmpty) {
      return double.negativeInfinity;
    }
    final viewSize = MediaQuery.sizeOf(context);
    final center = renderObject.localToGlobal(
      renderObject.size.center(Offset.zero),
    );
    const slop = 8.0;
    if (center.dx < -slop ||
        center.dx > viewSize.width + slop ||
        center.dy < -slop ||
        center.dy > viewSize.height + slop) {
      return double.negativeInfinity;
    }
    final viewCenter = Offset(viewSize.width / 2, viewSize.height / 2);
    return -(center - viewCenter).distanceSquared;
  }

  ScrollPosition? _findInnerScrollPosition() {
    ScrollPosition? best;
    var bestScore = double.negativeInfinity;
    ScrollPosition? firstInner;
    void visit(Element element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        final state = element.state as ScrollableState;
        try {
          final position = state.position;
          if (position.hasContentDimensions &&
              _isNestedInnerPosition(position)) {
            firstInner ??= position;
            final score = _currentInnerScore(state.context, position);
            if (score > bestScore) {
              bestScore = score;
              best = position;
            }
          }
        } catch (_) {}
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return best ?? firstInner;
  }

  ScrollPosition? _findLocalScrollPosition() {
    ScrollPosition? inner = _findInnerScrollPosition();
    if (inner != null) {
      return inner;
    }
    ScrollPosition? fallback;
    void visit(Element element) {
      if (fallback != null) {
        return;
      }
      if (element is StatefulElement && element.state is ScrollableState) {
        final state = element.state as ScrollableState;
        try {
          final position = state.position;
          if (position.hasContentDimensions &&
              position.debugLabel != 'outer' &&
              position.axis == Axis.vertical) {
            fallback = position;
          }
        } catch (_) {}
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return fallback;
  }

  void _bindLocalNestedPositions() {
    ScrollPosition? outerPos;
    void visit(Element element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        final state = element.state as ScrollableState;
        try {
          final position = state.position;
          if (position.hasContentDimensions && position.debugLabel == 'outer') {
            outerPos ??= position;
          }
        } catch (_) {}
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    final resolvedOuter = outerPos;
    final resolvedInner = _findInnerScrollPosition();
    if (resolvedOuter != null) {
      _headerNotifier._nestedOuterPosition = resolvedOuter;
      _footerNotifier._nestedOuterPosition = resolvedOuter;
      _headerNotifier.position = resolvedOuter;
    }
    if (resolvedInner != null) {
      _headerNotifier._nestedInnerPosition = resolvedInner;
      _footerNotifier._nestedInnerPosition = resolvedInner;
      _footerNotifier.position = resolvedInner;
    }
  }

  void _bindNestedControllers() {
    if (!mounted) {
      return;
    }
    ScrollController? outer = widget.nestedOuterController;
    ScrollController? inner = widget.nestedInnerController;
    final nestedState = _nestedHostLike();
    if (nestedState != null) {
      outer ??= _nestedHostOuterController();
      inner ??= _nestedHostInnerController();
    }
    if (outer == null && inner == null && nestedState == null) {
      if (!widget.isNested && _hasDescendantNestedScrollView()) {
        return;
      }
      _bindLocalNestedPositions();
      return;
    }
    if (outer != null && outer.hasClients) {
      final position = outer.position;
      _headerNotifier._nestedOuterPosition = position;
      _footerNotifier._nestedOuterPosition = position;
      _headerNotifier.position = position;
    }
    ScrollPosition? innerPosition = _findInnerScrollPosition();
    if (innerPosition == null && inner != null && inner.hasClients) {
      final current = _footerNotifier._nestedInnerPosition;
      if (current != null && inner.positions.contains(current)) {
        innerPosition = current;
      } else {
        innerPosition = inner.positions.last;
      }
    }
    if (innerPosition != null) {
      _headerNotifier._nestedInnerPosition = innerPosition;
      _footerNotifier._nestedInnerPosition = innerPosition;
      _footerNotifier.position = innerPosition;
    }
  }

  /// Refresh on start listener.
  /// From [IndicatorMode.processing] to [IndicatorMode.inactive].
  /// When back to inactive, end listening.
  void _refreshOnStartListener() {
    if (_headerNotifier._mode == IndicatorMode.inactive) {
      _isRefreshOnStart = false;
      _headerNotifier.removeListener(_refreshOnStartListener);
      _headerNotifier._update(indicator: _header, task: _onRefresh);
    }
  }

  /// Refresh callback.
  /// Handle [EasyRefresh.resetAfterRefresh].
  FutureOr Function()? get _onRefresh {
    if (widget.onRefresh == null) {
      return null;
    }
    return () async {
      // Start listening on refresh.
      if (_isRefreshOnStart) {
        _headerNotifier.addListener(_refreshOnStartListener);
      }
      final res = await Future.sync(widget.onRefresh!);
      // Reset Footer state.
      if (widget.resetAfterRefresh) {
        _footerNotifier._reset();
      }
      return res;
    };
  }

  /// Automatically trigger refresh.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future _callRefresh({
    double? overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    _bindNestedControllers();
    return _headerNotifier.callTask(
      overOffset: overOffset ?? widget.callRefreshOverOffset,
      duration: duration,
      curve: curve,
      scrollController:
          scrollController ??
          widget.nestedOuterController ??
          _nestedHostOuterController() ??
          widget.scrollController,
      force: force,
    );
  }

  /// Automatically trigger load.
  /// [overOffset] Offset beyond the trigger offset, must be greater than 0.
  /// [duration] See [ScrollPosition.animateTo].
  /// [curve] See [ScrollPosition.animateTo].
  /// [scrollController] When position is not [ScrollPosition], you can use [ScrollController].
  /// [force] Enforce execution even if the task is in progress. But you have to handle the completion event.
  Future _callLoad({
    double? overOffset,
    Duration? duration,
    Curve curve = Curves.linear,
    ScrollController? scrollController,
    bool force = false,
  }) {
    _bindNestedControllers();
    return _footerNotifier.callTask(
      overOffset: overOffset ?? widget.callLoadOverOffset,
      duration: duration,
      curve: curve,
      scrollController:
          scrollController ??
          widget.nestedInnerController ??
          _nestedHostInnerController() ??
          widget.scrollController,
      force: force,
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
        final safePadding = MediaQuery.of(context).padding;
        _headerNotifier._safeOffset = axis == Axis.vertical
            ? axisDirection == AxisDirection.down
                  ? safePadding.top
                  : safePadding.bottom
            : axisDirection == AxisDirection.right
            ? safePadding.left
            : safePadding.right;
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
        final safePadding = MediaQuery.of(context).padding;
        _footerNotifier._safeOffset = axis == Axis.vertical
            ? axisDirection == AxisDirection.down
                  ? safePadding.bottom
                  : safePadding.top
            : axisDirection == AxisDirection.right
            ? safePadding.right
            : safePadding.left;
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

  // a builder of scroll behavior
  ERScrollBehaviorBuilder get _scrollBehaviorBuilder =>
      widget.scrollBehaviorBuilder ?? EasyRefresh.defaultScrollBehaviorBuilder;

  /// Build content widget.
  Widget _buildContent() {
    Widget child;
    if (widget._nestedHeaderSliverBuilder != null) {
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(_physics),
        child: NestedScrollView(
          key: _nestedViewKey,
          controller: widget.scrollController,
          physics: _physics,
          scrollDirection: widget._nestedScrollDirection,
          reverse: widget._nestedReverse,
          floatHeaderSlivers: widget._nestedFloatHeaderSlivers,
          clipBehavior: widget._nestedClipBehavior,
          dragStartBehavior: widget._nestedDragStartBehavior,
          restorationId: widget._nestedRestorationId,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              if (widget.onRefresh != null)
                const HeaderLocator.sliver(clearExtent: false),
              ...widget._nestedHeaderSliverBuilder!(
                context,
                innerBoxIsScrolled,
              ),
            ];
          },
          body: widget._nestedBody!,
        ),
      );
    } else if (widget.childBuilder != null) {
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(null),
        child: widget.childBuilder!(context, _physics),
      );
    } else {
      child = ScrollConfiguration(
        behavior: _scrollBehaviorBuilder(_physics),
        child: widget.child!,
      );
    }
    return _InheritedEasyRefresh(data: _data, child: child);
  }

  @override
  Widget build(BuildContext context) {
    final contentWidget = _buildContent();
    final List<Widget> children = [];
    final hPosition = _headerNotifier.iPosition;
    final fPosition = _footerNotifier.iPosition;
    // Set the position of widgets.
    if (hPosition == IndicatorPosition.behind) {
      children.add(_buildHeaderView());
    }
    if (fPosition == IndicatorPosition.behind) {
      children.add(_buildFooterView());
    }
    children.add(contentWidget);
    if (hPosition == IndicatorPosition.above) {
      children.add(_buildHeaderView());
    }
    if (fPosition == IndicatorPosition.above) {
      children.add(_buildFooterView());
    }
    if (children.length == 1) {
      children.clear();
      return contentWidget;
    }
    return ClipPath(
      clipBehavior: widget.clipBehavior,
      child: Stack(
        clipBehavior: Clip.none,
        fit: widget.fit,
        children: children,
      ),
    );
  }
}
