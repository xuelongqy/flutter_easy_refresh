import 'dart:math' as math;

import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class ListenerHeaderPage extends StatefulWidget {
  const ListenerHeaderPage({Key? key}) : super(key: key);

  @override
  State<ListenerHeaderPage> createState() => _ListenerHeaderPageState();
}

class _ListenerHeaderPageState extends State<ListenerHeaderPage> {
  int _count = 10;
  late EasyRefreshController _controller;
  final _listenable = IndicatorStateListenable();

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
    return Scaffold(
      body: EasyRefresh(
        controller: _controller,
        header: ListenerHeader(
          triggerOffset: 100,
          listenable: _listenable,
          safeArea: false,
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
              _count >= 20 ? IndicatorResult.noMore : IndicatorResult.success);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                title: Text(
                  'Listener'.tr,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color),
                ),
              ),
              actions: [
                ValueListenableBuilder<IndicatorState?>(
                  valueListenable: _listenable,
                  builder: (context, state, _) {
                    if (state == null) {
                      return const SizedBox();
                    }
                    final mode = state.mode;
                    final offset = state.offset;
                    final actualTriggerOffset = state.actualTriggerOffset;
                    double? value;
                    if (mode == IndicatorMode.inactive) {
                      value = 0;
                    } else if (mode == IndicatorMode.processing) {
                      value = null;
                    } else if (mode == IndicatorMode.drag ||
                        mode == IndicatorMode.armed) {
                      value = math.min(offset / actualTriggerOffset, 1) * 0.75;
                    } else if (mode == IndicatorMode.ready ||
                        mode == IndicatorMode.processing) {
                      value == null;
                    } else {
                      value = 1;
                    }
                    Widget indicator;
                    if (value != null && value < 0.1) {
                      indicator = const SizedBox();
                    } else if (value == 1) {
                      indicator = Icon(
                        Icons.done,
                        color: themeData.colorScheme.primary,
                      );
                    } else {
                      indicator = RefreshProgressIndicator(
                        value: value,
                      );
                    }
                    return SizedBox(
                      width: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            reverseDuration: const Duration(milliseconds: 100),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: indicator,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
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
