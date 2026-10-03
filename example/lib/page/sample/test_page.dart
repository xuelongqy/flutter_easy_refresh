import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

enum _NestedRecipe {
  nested('EasyRefresh.nested'),
  builder('Builder + Nested'),
  extended('Builder + Extended'),
  perList('Extended + list Header');

  const _NestedRecipe(this.label);
  final String label;
}

/// Manual comparison of tall collapsing headers and nested refresh recipes.
class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _outerController = ScrollController(keepScrollOffset: false);
  var _headerState = IndicatorStateListenable();
  late Listenable _status;
  _NestedRecipe _recipe = _NestedRecipe.nested;
  double _height = 1000;
  bool _shortList = false;
  bool _refreshing = false;
  int _refreshCount = 0;
  late Widget _nestedContent;

  @override
  void initState() {
    super.initState();
    _status = Listenable.merge([_outerController, _headerState]);
    _nestedContent = _buildNested();
  }

  void _changeConfiguration(VoidCallback change) {
    setState(() {
      change();
      // Each remounted EasyRefresh owns its own indicator binding.
      _headerState = IndicatorStateListenable();
      _status = Listenable.merge([_outerController, _headerState]);
      _nestedContent = KeyedSubtree(key: UniqueKey(), child: _buildNested());
    });
  }

  @override
  void dispose() {
    _outerController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _refreshing = true;
      _refreshCount++;
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _refreshing = false);
  }

  Header get _header => OverrideHeader(
    listenable: _headerState,
    header: ClassicHeader(
      clamping: true,
      position: IndicatorPosition.locator,
      safeArea: false,
      dragText: 'Pull to refresh'.tr,
      armedText: 'Release ready'.tr,
      readyText: 'Refreshing...'.tr,
      processingText: 'Refreshing...'.tr,
      processedText: 'Succeeded'.tr,
      noMoreText: 'No more'.tr,
      failedText: 'Failed'.tr,
      messageText: 'Last updated at %T'.tr,
    ),
  );

  List<Widget> _slivers(BuildContext context, bool scrolled) {
    final colors = Theme.of(context).colorScheme;
    return [
      if (_recipe != _NestedRecipe.nested && _recipe != _NestedRecipe.perList)
        const HeaderLocator.sliver(clearExtent: false),
      SliverAppBar(
        primary: false,
        automaticallyImplyLeading: false,
        pinned: true,
        expandedHeight: _height,
        backgroundColor: colors.primaryContainer,
        foregroundColor: colors.onPrimaryContainer,
        title: Text('Collapsing area'.tr),
        flexibleSpace: ColoredBox(
          color: colors.primaryContainer,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 90, 24, 0),
              child: Text(
                '${_height.toInt()} px\n${'Tall header drag hint'.tr}',
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.onPrimaryContainer),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _list([ScrollPhysics? physics]) => ListView.builder(
    padding: EdgeInsets.zero,
    physics: physics,
    itemCount: _shortList ? 1 : 30,
    itemBuilder: (context, index) => const SkeletonItem(),
  );

  Widget _buildNested() {
    if (_recipe == _NestedRecipe.nested) {
      return EasyRefresh.nested(
        scrollController: _outerController,
        header: _header,
        onRefresh: _refresh,
        headerSliverBuilder: _slivers,
        body: _list(),
      );
    }
    return EasyRefresh.builder(
      isNested: true,
      header: _recipe == _NestedRecipe.perList ? null : _header,
      onRefresh: _recipe == _NestedRecipe.perList ? null : _refresh,
      childBuilder: (context, physics) {
        if (_recipe == _NestedRecipe.builder) {
          return NestedScrollView(
            controller: _outerController,
            physics: physics,
            headerSliverBuilder: _slivers,
            body: _list(physics),
          );
        }
        return ExtendedNestedScrollView(
          controller: _outerController,
          physics: physics,
          onlyOneScrollInBody: true,
          pinnedHeaderSliverHeightBuilder: () => kToolbarHeight,
          headerSliverBuilder: _slivers,
          body: _recipe == _NestedRecipe.perList
              ? EasyRefresh.builder(
                  isNested: true,
                  header: _header,
                  onRefresh: _refresh,
                  childBuilder: (context, innerPhysics) => CustomScrollView(
                    physics: innerPhysics,
                    slivers: [
                      const HeaderLocator.sliver(clearExtent: false),
                      SliverList.builder(
                        itemCount: _shortList ? 1 : 30,
                        itemBuilder: (context, index) => const SkeletonItem(),
                      ),
                    ],
                  ),
                )
              : _list(physics),
        );
      },
    );
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text('Tall nested header test'.tr),
        content: Text('Tall nested header instructions'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it'.tr),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tall nested header test'.tr),
        actions: [
          IconButton(
            tooltip: 'Tall nested header help'.tr,
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            tooltip: 'Reset test'.tr,
            onPressed: _refreshing
                ? null
                : () => _changeConfiguration(() {
                    _refreshCount = 0;
                  }),
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DropdownButton<_NestedRecipe>(
                    isExpanded: true,
                    value: _recipe,
                    items: [
                      for (final recipe in _NestedRecipe.values)
                        DropdownMenuItem(
                          value: recipe,
                          child: Text(recipe.label.tr),
                        ),
                    ],
                    onChanged: _refreshing
                        ? null
                        : (value) => _changeConfiguration(() {
                            _recipe = value!;
                          }),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButton<double>(
                    isExpanded: true,
                    value: _height,
                    items: [
                      for (final height in [200.0, 600.0, 1000.0, 1600.0])
                        DropdownMenuItem(
                          value: height,
                          child: Text('${height.toInt()} px'),
                        ),
                    ],
                    onChanged: _refreshing
                        ? null
                        : (value) => _changeConfiguration(() {
                            _height = value!;
                          }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Short list'.tr),
                Switch(
                  value: _shortList,
                  onChanged: _refreshing
                      ? null
                      : (value) => _changeConfiguration(() {
                          _shortList = value;
                        }),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _refreshing
                      ? null
                      : () {
                          if (_outerController.hasClients) {
                            _outerController.jumpTo(
                              _outerController.position.maxScrollExtent,
                            );
                          }
                        },
                  child: Text('Collapse'.tr),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _status,
            builder: (context, child) {
              final outer = _outerController.hasClients
                  ? _outerController.position.pixels.toStringAsFixed(0)
                  : '0';
              final state = _headerState.value;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  '${'Refresh count'.tr}: $_refreshCount · Outer: $outer px\n'
                  'Header: ${state?.mode.name ?? 'inactive'} · '
                  '${(state?.offset ?? 0).toStringAsFixed(1)} px',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
          Expanded(child: _nestedContent),
        ],
      ),
    );
  }
}
