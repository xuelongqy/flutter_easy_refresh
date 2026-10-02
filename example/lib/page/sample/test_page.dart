import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:material_ui/material_ui.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _recoverFromOutside({required bool footer}) async {
    final position = _scrollController.position;
    final edge = footer ? position.maxScrollExtent : position.minScrollExtent;
    final outside = edge + (footer ? 40 : -40);
    _scrollController.jumpTo(outside);
    await _scrollController.animateTo(
      edge,
      duration: const Duration(milliseconds: 600),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue #650 · maxOverOffset')),
      body: EasyRefresh(
        header: const ClassicHeader(maxOverOffset: 0),
        footer: const ClassicFooter(infiniteOffset: null, maxOverOffset: 0),
        onRefresh: () async {},
        onLoad: () async {},
        child: ListView.builder(
          controller: _scrollController,
          itemCount: 20,
          itemBuilder: (context, index) => const SkeletonItem(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '模拟当前位置已经超过 maxOverOffset，然后向合法区域恢复。'
                '修复前会触发 applyBoundaryConditions overscroll 断言。',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _recoverFromOutside(footer: false),
                      child: const Text('Header 恢复'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _recoverFromOutside(footer: true),
                      child: const Text('Footer 恢复'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
