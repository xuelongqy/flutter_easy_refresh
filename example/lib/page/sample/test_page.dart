import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:material_ui/material_ui.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  int _count = 20;
  int _loadCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Issue #831 · $_count items')),
      body: EasyRefresh(
        footer: const ClassicFooter(
          position: IndicatorPosition.locator,
          hitOver: true,
          infiniteHitOver: true,
        ),
        onLoad: () async {
          _loadCount++;
          await Future<void>.delayed(const Duration(milliseconds: 300));
          if (!mounted) {
            return;
          }
          setState(() => _count += 10);
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const SkeletonItem(),
                childCount: _count,
              ),
            ),
            const FooterLocator.sliver(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '快速上拉到底触发加载；300ms 后追加 10 条。'
            '修复后列表不应继承旧 Footer 回弹速度继续向上滑。'
            '  Load: $_loadCount',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
