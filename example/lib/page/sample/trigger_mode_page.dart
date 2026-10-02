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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indicator trigger mode'.tr)),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Header starts at edge'.tr),
            subtitle: Text(
              (_headerTriggerMode == IndicatorTriggerMode.onEdge
                      ? 'Header onEdge mode description'
                      : 'Header anywhere mode description')
                  .tr,
            ),
            value: _headerTriggerMode == IndicatorTriggerMode.onEdge,
            onChanged: (value) {
              setState(() {
                _headerTriggerMode = value
                    ? IndicatorTriggerMode.onEdge
                    : IndicatorTriggerMode.anywhere;
              });
            },
          ),
          SwitchListTile(
            title: Text('Footer starts at edge'.tr),
            subtitle: Text(
              (_footerTriggerMode == IndicatorTriggerMode.onEdge
                      ? 'Footer onEdge mode description'
                      : 'Footer anywhere mode description')
                  .tr,
            ),
            value: _footerTriggerMode == IndicatorTriggerMode.onEdge,
            onChanged: (value) {
              setState(() {
                _footerTriggerMode = value
                    ? IndicatorTriggerMode.onEdge
                    : IndicatorTriggerMode.anywhere;
              });
            },
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
                  if (index == 0) {
                    return ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(
                        'Refresh count: @count'.trParams({
                          'count': '$_refreshCount',
                        }),
                      ),
                      subtitle: Text(
                        '${'Load count: @count'.trParams({'count': '$_loadCount'})}\n'
                        '${'Trigger mode test instruction'.tr}',
                      ),
                    );
                  }
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
    );
  }
}
