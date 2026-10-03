import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class TriggerModePage extends StatefulWidget {
  const TriggerModePage({super.key});

  @override
  State<TriggerModePage> createState() => _TriggerModePageState();
}

class _TriggerModePageState extends State<TriggerModePage> {
  var _headerTriggerMode = IndicatorTriggerMode.onEdge;
  var _footerTriggerMode = IndicatorTriggerMode.onEdge;
  var _refreshCount = 0;
  var _loadCount = 0;

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Trigger mode help'.tr),
        scrollable: true,
        content: Text(
          '${'Trigger mode test instruction'.tr}\n\n'
          'Header · ${_headerTriggerMode.name}\n'
          '${(_headerTriggerMode == IndicatorTriggerMode.onEdge ? 'Header onEdge mode description' : 'Header anywhere mode description').tr}\n\n'
          'Footer · ${_footerTriggerMode.name}\n'
          '${(_footerTriggerMode == IndicatorTriggerMode.onEdge ? 'Footer onEdge mode description' : 'Footer anywhere mode description').tr}',
        ),
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
        title: Text('Indicator trigger mode'.tr),
        actions: [
          IconButton(
            tooltip: 'Trigger mode help'.tr,
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Header'),
                      subtitle: Text(_headerTriggerMode.name),
                      value: _headerTriggerMode == IndicatorTriggerMode.onEdge,
                      onChanged: (value) {
                        setState(() {
                          _headerTriggerMode = value
                              ? IndicatorTriggerMode.onEdge
                              : IndicatorTriggerMode.anywhere;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Footer'),
                      subtitle: Text(_footerTriggerMode.name),
                      value: _footerTriggerMode == IndicatorTriggerMode.onEdge,
                      onChanged: (value) {
                        setState(() {
                          _footerTriggerMode = value
                              ? IndicatorTriggerMode.onEdge
                              : IndicatorTriggerMode.anywhere;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodySmall!,
                  child: Wrap(
                    spacing: 16,
                    children: [
                      Text(
                        'Refresh count: @count'.trParams({
                          'count': '$_refreshCount',
                        }),
                      ),
                      Text(
                        'Load count: @count'.trParams({'count': '$_loadCount'}),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: EasyRefresh(
                header: ClassicHeader(triggerMode: _headerTriggerMode),
                footer: ClassicFooter(
                  triggerMode: _footerTriggerMode,
                  infiniteOffset: null,
                ),
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _refreshCount++;
                  });
                },
                onLoad: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _loadCount++;
                  });
                },
                child: ListView.builder(
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: Text(
                        'Item @index'.trParams({'index': '${index + 1}'}),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
