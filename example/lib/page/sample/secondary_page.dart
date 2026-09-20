import 'package:example/widget/skeleton_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

class SecondaryPage extends StatefulWidget {
  const SecondaryPage({super.key});

  @override
  State<SecondaryPage> createState() => _SecondaryPageState();
}

class _SecondaryPageState extends State<SecondaryPage> {
  int _count = 10;
  bool _callOpenSecondary = false;
  final _secondaryPageKey = GlobalKey();
  late EasyRefreshController _controller;
  final _listenable = IndicatorStateListenable();
  late final FileLoader _riveFileLoader;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    // https://rive.app/marketplace/25759-48234-slot-machine-game-with-scripting/
    _riveFileLoader = FileLoader.fromAsset(
      'assets/rive/machine-game.riv',
      riveFactory: Factory.rive,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _riveFileLoader.dispose();
    super.dispose();
  }

  bool _secondaryForeground(IndicatorMode? mode) =>
      mode == IndicatorMode.secondaryReady ||
      mode == IndicatorMode.secondaryOpen ||
      mode == IndicatorMode.secondaryClosing;

  double _primaryOpacity(IndicatorState? state) {
    if (state == null || state.offset <= state.actualTriggerOffset) return 1;
    return ((state.actualSecondaryTriggerOffset! - state.offset) /
            (state.actualSecondaryTriggerOffset! - state.actualTriggerOffset))
        .clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final appBarBackgroundColor =
        themeData.appBarTheme.backgroundColor ?? themeData.colorScheme.surface;
    return Scaffold(
      body: Stack(
        children: [
          EasyRefresh(
            controller: _controller,
            clipBehavior: Clip.none,
            header: SecondaryBuilderHeader(
              header: ClassicHeader(
                mainAxisAlignment: MainAxisAlignment.end,
                position: IndicatorPosition.locator,
                dragText: 'Pull to refresh'.tr,
                armedText: 'Release ready'.tr,
                readyText: 'Refreshing...'.tr,
                processingText: 'Refreshing...'.tr,
                processedText: 'Succeeded'.tr,
                noMoreText: 'No more'.tr,
                failedText: 'Failed'.tr,
                messageText: 'Last updated at %T'.tr,
                safeArea: false,
                clipBehavior: Clip.none,
              ),
              secondaryTriggerOffset: 120,
              secondaryDimension:
                  size.height - kToolbarHeight - mediaQuery.padding.top,
              listenable: _listenable,
              builder: (context, state, header) {
                final mode = state.mode;
                final scale = _primaryOpacity(state);
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(height: state.offset, width: double.infinity),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SizedBox(
                        height: size.height,
                        width: double.infinity,
                        child: Builder(
                          builder: (context) {
                            Widget secondaryPage = Opacity(
                              key: _secondaryPageKey,
                              opacity: 1 - scale,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: RiveWidgetBuilder(
                                      fileLoader: _riveFileLoader,
                                      builder: (context, state) =>
                                          switch (state) {
                                            RiveLoading() => const SizedBox(),
                                            RiveFailed() => SizedBox(
                                              child: Center(
                                                child: Text(
                                                  state.error.toString(),
                                                  style: themeData
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                            ),
                                            RiveLoaded() => RiveWidget(
                                              controller: state.controller,
                                              fit: Fit.cover,
                                            ),
                                          },
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (_secondaryForeground(mode)) {
                              return PopScope(
                                canPop: false,
                                onPopInvokedWithResult: (_, _) {
                                  _controller.closeHeaderSecondary();
                                },
                                child: secondaryPage,
                              );
                            }
                            return secondaryPage;
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity:
                              mode == IndicatorMode.secondaryArmed &&
                                  !_callOpenSecondary
                              ? 1
                              : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            'Open the second floor'.tr,
                            style: themeData.textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                    Opacity(
                      opacity:
                          (mode == IndicatorMode.secondaryReady ||
                              mode == IndicatorMode.secondaryOpen ||
                              mode == IndicatorMode.secondaryClosing)
                          ? 0
                          : scale,
                      child: header.build(context, state),
                    ),
                  ],
                );
              },
            ),
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) {
                return;
              }
              setState(() {
                _count = 10;
              });
              _controller.finishRefresh();
              _controller.resetFooter();
            },
            onLoad: () async {
              await Future.delayed(const Duration(seconds: 2));
              if (!mounted) {
                return;
              }
              setState(() {
                _count += 5;
              });
              _controller.finishLoad(
                _count >= 20 ? IndicatorResult.noMore : IndicatorResult.success,
              );
            },
            child: CustomScrollView(
              slivers: [
                ValueListenableBuilder<IndicatorState?>(
                  valueListenable: _listenable,
                  builder: (context, state, child) {
                    final scale = _primaryOpacity(state);
                    return SliverIgnorePointer(
                      ignoring: _secondaryForeground(state?.mode) || scale == 0,
                      sliver: SliverOpacity(
                        opacity: scale,
                        sliver: SliverAppBar(
                          pinned: true,
                          backgroundColor: Color.lerp(
                            Colors.transparent,
                            appBarBackgroundColor,
                            scale,
                          ),
                          surfaceTintColor: Colors.transparent,
                          systemOverlayStyle: SystemUiOverlayStyle.dark,
                          foregroundColor: Colors.black,
                          title: Text('Secondary'.tr),
                          actions: [
                            IconButton(
                              key: const Key('secondary-open'),
                              tooltip: 'Open the second floor'.tr,
                              onPressed: () async {
                                _callOpenSecondary = true;
                                await _controller.openHeaderSecondary();
                                _callOpenSecondary = false;
                              },
                              icon: const Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const HeaderLocator.sliver(),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return const SkeletonItem();
                  }, childCount: _count),
                ),
              ],
            ),
          ),
          // This toolbar has real viewport bounds above the pinned main bar.
          // The secondary body stays in the Header so its scroll gestures work.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<IndicatorState?>(
              valueListenable: _listenable,
              builder: (context, state, _) {
                if (!_secondaryForeground(state?.mode)) {
                  return const SizedBox.shrink();
                }
                final opacity = 1 - _primaryOpacity(state);
                return IgnorePointer(
                  ignoring: opacity == 0,
                  child: Opacity(
                    opacity: opacity,
                    child: SizedBox(
                      height: mediaQuery.padding.top + kToolbarHeight,
                      child: AppBar(
                        key: const Key('secondary-app-bar'),
                        backgroundColor: Colors.transparent,
                        surfaceTintColor: Colors.transparent,
                        elevation: 0,
                        systemOverlayStyle: SystemUiOverlayStyle.dark,
                        foregroundColor: Colors.black,
                        leading: BackButton(
                          key: const Key('secondary-back'),
                          onPressed: _controller.closeHeaderSecondary,
                        ),
                        title: Text('Secondary'.tr),
                        actions: [
                          IconButton(
                            key: const Key('secondary-close'),
                            tooltip: 'Close second floor'.tr,
                            onPressed: _controller.closeHeaderSecondary,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
