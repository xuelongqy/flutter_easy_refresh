import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class CenterRefreshPage extends StatefulWidget {
  const CenterRefreshPage({super.key});

  @override
  State<CenterRefreshPage> createState() => _CenterRefreshPageState();
}

class _CenterRefreshPageState extends State<CenterRefreshPage> {
  final _centerKey = GlobalKey();
  int _newItemCount = 0;
  int _itemCount = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Centered refresh'.tr)),
      body: EasyRefresh.builder(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _newItemCount += 5;
          });
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _itemCount += 5;
          });
        },
        childBuilder: (context, physics) {
          return CustomScrollView(
            physics: physics,
            center: _centerKey,
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ItemCard(
                    title: 'New item @index'.trParams({
                      'index': '${index + 1}',
                    }),
                  ),
                  childCount: _newItemCount,
                ),
              ),
              SliverList(
                key: _centerKey,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ItemCard(
                    title: 'Item @index'.trParams({'index': '${index + 1}'}),
                  ),
                  childCount: _itemCount,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.article_outlined),
        title: Text(title),
      ),
    );
  }
}
