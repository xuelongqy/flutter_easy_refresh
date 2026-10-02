import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

class TriggerModePage extends StatefulWidget {
  const TriggerModePage({super.key});

  @override
  State<TriggerModePage> createState() => _TriggerModePageState();
}

class _TriggerModePageState extends State<TriggerModePage> {
  var _triggerMode = IndicatorTriggerMode.onEdge;
  var _refreshCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Header trigger mode'.tr)),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Trigger only when drag starts at the edge'.tr),
            subtitle: Text(
              (_triggerMode == IndicatorTriggerMode.onEdge
                      ? 'onEdge mode description'
                      : 'anywhere mode description')
                  .tr,
            ),
            value: _triggerMode == IndicatorTriggerMode.onEdge,
            onChanged: (value) {
              setState(() {
                _triggerMode = value
                    ? IndicatorTriggerMode.onEdge
                    : IndicatorTriggerMode.anywhere;
              });
            },
          ),
          Expanded(
            child: EasyRefresh(
              header: ClassicHeader(triggerMode: _triggerMode),
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
                if (!mounted) {
                  return;
                }
                setState(() {
                  _refreshCount++;
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
                      subtitle: Text('Trigger mode test instruction'.tr),
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
