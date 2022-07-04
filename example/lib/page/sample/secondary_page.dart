import 'dart:math' as math;

import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:rive/rive.dart';

class SecondaryPage extends StatefulWidget {
  const SecondaryPage({Key? key}) : super(key: key);

  @override
  State<SecondaryPage> createState() => _SecondaryPageState();
}

class _SecondaryPageState extends State<SecondaryPage> {
  int _count = 10;
  late EasyRefreshController _controller;
  final _listenable = IndicatorStateListenable();
  final _secondaryPageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    return Scaffold(
      body: EasyRefresh(
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
            double scale = 1;
            if (state.offset > state.actualTriggerOffset) {
              scale = math.max(
                  0.0,
                  (state.actualSecondaryTriggerOffset! - state.offset) /
                      (state.actualSecondaryTriggerOffset! -
                          state.actualTriggerOffset));
            }
            return Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: state.offset,
                  width: double.infinity,
                ),
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
                              const RiveAnimation.asset(
                                'assets/rive/raster_graphics.riv',
                                fit: BoxFit.cover,
                              ),
                              Column(
                                children: [
                                  AppBar(
                                    backgroundColor: Colors.transparent,
                                    systemOverlayStyle:
                                        SystemUiOverlayStyle.dark,
                                    foregroundColor: Colors.black,
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                        if (mode == IndicatorMode.secondaryOpen ||
                            mode == IndicatorMode.secondaryClosing) {
                          return WillPopScope(
                            onWillPop: () async {
                              return false;
                            },
                            child: secondaryPage,
                          );
                        }
                        return secondaryPage;
                      },
                    ),
                  ),
                ),
                Opacity(
                  opacity: (mode == IndicatorMode.secondaryReady ||
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
          setState(() {
            _count = 10;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(_count >= 20
              ? IndicatorResult.noMore
              : IndicatorResult.succeeded);
        },
        child: CustomScrollView(
          slivers: [
            ValueListenableBuilder<IndicatorState?>(
              valueListenable: _listenable,
              builder: (context, state, child) {
                double scale = 1;
                if (state != null) {
                  if (state.offset > state.actualTriggerOffset) {
                    scale = math.max(
                        0.0,
                        (state.actualSecondaryTriggerOffset! - state.offset) /
                            (state.actualSecondaryTriggerOffset! -
                                state.actualTriggerOffset));
                  }
                }
                return SliverOpacity(
                  opacity: scale,
                  sliver: SliverAppBar(
                    title: Text('Secondary'.tr),
                    pinned: true,
                  ),
                );
              },
            ),
            const HeaderLocator.sliver(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return const SkeletonItem();
                },
                childCount: _count,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
