import 'dart:async';

import 'package:example/widget/sample_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _scrollDirection = Axis.vertical;

  int _count = 0;

  final _controller = EasyRefreshController(
    controlFinishRefresh: true,
  );

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(seconds: 1), () {
    //   PrimaryScrollController.of(context)!.position.jumpTo(-70);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EasyRefresh'),
      ),
      body: EasyRefresh(
        noMoreRefresh: false,
        noMoreLoad: false,
        refreshOnStart: true,
        controller: _controller,
        refreshOnStartHeader: BuilderHeader(
            triggerOffset: 70,
            clamping: false,
            position: IndicatorPosition.locator,
            processedDuration: Duration.zero,
            builder: (ctx, state) {
              if (state.mode == IndicatorMode.inactive) {
                return const SizedBox();
              }
              return Container(
                width: double.infinity,
                height: state.viewportDimension,
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text('Refresh on start'),
              );
            }),
        onRefresh: () async {
          print('Refreshing');
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count = 5;
          });
          print('Refreshed');
          _controller.finishRefresh(IndicatorResult.succeeded);
          return IndicatorResult.succeeded;
        },
        onLoad: () async {
          print('Loading');
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count += 5;
          });
          print('Loaded');
          return IndicatorResult.noMore;
        },
        // child: ListView.builder(
        //   padding: EdgeInsets.zero,
        //   scrollDirection: scrollDirection,
        //   itemCount: _count,
        //   itemBuilder: (context, index) {
        //     return SampleListItem(
        //       direction: scrollDirection,
        //       width: scrollDirection == Axis.vertical ? double.infinity : 200,
        //     );
        //   },
        // ),
        // child: ListView(
        //   scrollDirection: scrollDirection,
        //   reverse: true,
        //   children: [
        //     const HeaderLocator(),
        //     for (int i = 0; i < _count; i++)
        //       SampleListItem(
        //         direction: scrollDirection,
        //         width: scrollDirection == Axis.vertical ? double.infinity : 200,
        //       ),
        //     const FooterLocator(),
        //   ],
        // ),
        child: CustomScrollView(
          scrollDirection: _scrollDirection,
          reverse: false,
          slivers: [
            const HeaderLocator.sliver(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return SampleListItem(
                    direction: _scrollDirection,
                    width: _scrollDirection == Axis.vertical
                        ? double.infinity
                        : 200,
                  );
                },
                childCount: _count,
              ),
            ),
            const FooterLocator.sliver(),
          ],
        ),
      ),
    );
  }
}
