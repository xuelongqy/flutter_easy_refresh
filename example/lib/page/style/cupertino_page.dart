import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoIndicatorPage extends StatefulWidget {
  const CupertinoIndicatorPage({Key? key}) : super(key: key);

  @override
  State<CupertinoIndicatorPage> createState() => _CupertinoIndicatorPageState();
}

class _CupertinoIndicatorPageState extends State<CupertinoIndicatorPage> {
  Axis _scrollDirection = Axis.vertical;
  int _count = 10;
  late EasyRefreshController _controller;

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
    return Material(
      color: Colors.transparent,
      child: CupertinoPageScaffold(
        navigationBar: _scrollDirection == Axis.vertical
            ? null
            : CupertinoNavigationBar(
                middle: Text(
                  'iOS Cupertino',
                  style: TextStyle(
                    color: themeData.textTheme.titleMedium?.color,
                  ),
                ),
                trailing: IconButton(
                  iconSize: 24,
                  onPressed: () {
                    setState(() {
                      _scrollDirection = _scrollDirection == Axis.horizontal
                          ? Axis.vertical
                          : Axis.horizontal;
                    });
                  },
                  icon: Icon(_scrollDirection == Axis.horizontal
                      ? Icons.horizontal_distribute
                      : Icons.vertical_distribute),
                ),
              ),
        child: SafeArea(
          top: _scrollDirection == Axis.horizontal,
          bottom: false,
          left: false,
          right: false,
          child: EasyRefresh(
            controller: _controller,
            header: const CupertinoHeader(
              position: IndicatorPosition.locator,
              safeArea: false,
            ),
            footer: const CupertinoFooter(
              position: IndicatorPosition.locator,
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
              _controller.finishLoad(_count >= 20
                  ? IndicatorResult.noMore
                  : IndicatorResult.success);
            },
            child: CustomScrollView(
              scrollDirection: _scrollDirection,
              slivers: [
                if (_scrollDirection == Axis.vertical)
                  CupertinoSliverNavigationBar(
                    largeTitle: Text(
                      'iOS Cupertino',
                      style: TextStyle(
                        color: themeData.textTheme.titleMedium?.color,
                      ),
                    ),
                    trailing: IconButton(
                      iconSize: 24,
                      onPressed: () {
                        setState(() {
                          _scrollDirection = _scrollDirection == Axis.horizontal
                              ? Axis.vertical
                              : Axis.horizontal;
                        });
                      },
                      icon: Icon(_scrollDirection == Axis.horizontal
                          ? Icons.horizontal_distribute
                          : Icons.vertical_distribute),
                    ),
                  ),
                const HeaderLocator.sliver(),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SkeletonItem(
                        direction: _scrollDirection,
                      );
                    },
                    childCount: _count,
                  ),
                ),
                const FooterLocator.sliver(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
