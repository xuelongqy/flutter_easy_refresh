import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class RefreshMutipleTimesPage extends StatefulWidget {
  const RefreshMutipleTimesPage({Key? key}) : super(key: key);

  @override
  State<RefreshMutipleTimesPage> createState() =>
      _RefreshMutipleTimesPageState();
}

class _RefreshMutipleTimesPageState extends State<RefreshMutipleTimesPage> {
  late EasyRefreshController _controller;
  int _count = 10;
  final Axis _scrollDirection = Axis.vertical;
  final _CIProperties _headerProperties = _CIProperties(
    name: 'Header',
    alignment: MainAxisAlignment.center,
    infinite: false,
  );
  final _CIProperties _footerProperties = _CIProperties(
    name: 'Footer',
    alignment: MainAxisAlignment.start,
    infinite: true,
  );
  var _selectFilterConditions = <String>[];

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
    final propertiesItems = [_headerProperties, _footerProperties];
    return Scaffold(
      appBar: AppBar(
        title: Text('Classic'.tr),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
              height: 50,
              color: Colors.black12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _conditionButtons(),
              )),
        ),
      ),
      body: EasyRefresh(
        clipBehavior: Clip.none,
        controller: _controller,
        header: ClassicHeader(
          clamping: _headerProperties.clamping,
          backgroundColor: _headerProperties.background
              ? Theme.of(context).colorScheme.surfaceVariant
              : null,
          mainAxisAlignment: _headerProperties.alignment,
          showMessage: _headerProperties.message,
          showText: _headerProperties.text,
          infiniteOffset: _headerProperties.infinite ? 70 : null,
          triggerWhenReach: _headerProperties.immediately,
          dragText: 'Pull to refresh'.tr,
          armedText: 'Release ready'.tr,
          readyText: 'Refreshing...'.tr,
          processingText: 'Refreshing...'.tr,
          processedText: 'Succeeded'.tr,
          noMoreText: 'No more'.tr,
          failedText: 'Failed'.tr,
          messageText: 'Last updated at %T'.tr,
        ),
        footer: ClassicFooter(
          clamping: _footerProperties.clamping,
          backgroundColor: _footerProperties.background
              ? Theme.of(context).colorScheme.surfaceVariant
              : null,
          mainAxisAlignment: _footerProperties.alignment,
          showMessage: _footerProperties.message,
          showText: _footerProperties.text,
          infiniteOffset: _footerProperties.infinite ? 70 : null,
          triggerWhenReach: _footerProperties.immediately,
          dragText: 'Pull to load'.tr,
          armedText: 'Release ready'.tr,
          readyText: 'Loading...'.tr,
          processingText: 'Loading...'.tr,
          processedText: 'Succeeded'.tr,
          noMoreText: 'No more'.tr,
          failedText: 'Failed'.tr,
          messageText: 'Last updated at %T'.tr,
        ),
        onRefresh: _headerProperties.disable
            ? null
            : () async {
                _refreshData();
              },
        onLoad: _footerProperties.disable
            ? null
            : () async {
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
        child: ListView.builder(
          clipBehavior: Clip.none,
          scrollDirection: _scrollDirection,
          padding: EdgeInsets.zero,
          itemCount: _count,
          itemBuilder: (ctx, index) {
            return SkeletonItem(
              direction: _scrollDirection,
            );
          },
        ),
      ),
    );
  }

  /// refresh data
  void _refreshData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    setState(() {
      _count = 10;
    });
    _controller.finishRefresh();
    _controller.resetFooter();
  }

  /// filter condition list
  List<Widget> _conditionButtons() {
    List<String> titles = ["筛选条件1", "筛选条件2", "筛选条件3", "筛选条件4"];
    return titles
        .map(
          (e) => Container(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: TextButton(
              child: Text(e),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.resolveWith(
                  (states) {
                    return const Size(50, 30);
                  },
                ),
                shape: MaterialStateProperty.resolveWith((states) {
                  return RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  );
                }),
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return _selectFilterConditions.contains(e) ? Colors.orange : Colors.white;
                  },
                ),
              ),
              onPressed: () {
                setState(() {
                  if (_selectFilterConditions.contains(e)) {
                    _selectFilterConditions.remove(e);
                  } else {
                    _selectFilterConditions.add(e);
                  }
                  _controller.callRefresh();
                  _refreshData();
                });
              },
            ),
          ),
        )
        .toList();
  }
}

/// Classic indicator properties.
class _CIProperties {
  final String name;
  bool disable = false;
  bool clamping = false;
  bool background = false;
  MainAxisAlignment alignment;
  bool message = true;
  bool text = true;
  bool infinite;
  bool immediately = false;

  _CIProperties({
    required this.name,
    required this.alignment,
    required this.infinite,
  });
}
