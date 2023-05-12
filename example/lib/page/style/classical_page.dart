import 'package:example/config/routes.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/menu_bottom_bar.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class ClassicPage extends StatefulWidget {
  const ClassicPage({Key? key}) : super(key: key);

  @override
  State<ClassicPage> createState() => _ClassicPageState();
}

class _ClassicPageState extends State<ClassicPage> {
  late EasyRefreshController _controller;
  int _count = 10;
  Axis _scrollDirection = Axis.vertical;
  int _expandedIndex = -1;
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
      bottomNavigationBar: MenuBottomBar(
        onRefresh: () => _controller.callRefresh(),
        onLoad: () => _controller.callLoad(),
        expandedBody: Column(
          children: [
            const SizedBox(height: 16),
            Obx(() {
              final themeMode = ThemeController.i.themeModel;
              return ListTile(
                title: Text('Theme'.tr),
                trailing: IntrinsicWidth(
                  child: Row(
                    children: [
                      if (themeMode.icon != null) Icon(themeMode.icon),
                      if (themeMode.color != null)
                        Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: themeMode.color,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                        ),
                      const SizedBox(width: 16),
                      Text(ThemeController.i.theme.value.tr),
                    ],
                  ),
                ),
                onTap: () => Get.toNamed(Routes.theme),
              );
            }),
            ListTile(
              title: Text('Direction'.tr),
              trailing: IntrinsicWidth(
                child: Row(
                  children: [
                    Radio<Axis>(
                      value: Axis.vertical,
                      groupValue: _scrollDirection,
                      onChanged: (value) {
                        setState(() {
                          _scrollDirection = value!;
                        });
                      },
                    ),
                    Text('Vertical'.tr),
                    Radio<Axis>(
                      value: Axis.horizontal,
                      groupValue: _scrollDirection,
                      onChanged: (value) {
                        setState(() {
                          _scrollDirection = value!;
                        });
                      },
                    ),
                    Text('Horizontal'.tr),
                  ],
                ),
              ),
            ),
            ExpansionPanelList(
              dividerColor: Colors.transparent,
              expansionCallback: (panelIndex, isExpanded) {
                setState(() {
                  if (!isExpanded) {
                    _expandedIndex = panelIndex;
                  } else {
                    _expandedIndex = -1;
                  }
                });
              },
              children: [
                for (int i = 0; i < propertiesItems.length; i++)
                  ExpansionPanel(
                    canTapOnHeader: true,
                    headerBuilder: (ctx, isExpanded) {
                      return ListTile(
                        title: Text(propertiesItems[i].name),
                        selected: isExpanded,
                      );
                    },
                    body: Builder(
                      builder: (ctx) {
                        final properties = propertiesItems[i];
                        return Column(
                          children: [
                            ListTile(
                              title: Text('Disable'.tr),
                              trailing: Switch(
                                value: properties.disable,
                                onChanged: (value) {
                                  setState(() {
                                    properties.disable = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Clamping'.tr),
                              trailing: Switch(
                                value: properties.clamping,
                                onChanged: (value) {
                                  setState(() {
                                    properties.clamping = value;
                                    if (value && properties.infinite) {
                                      properties.infinite = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Background'.tr),
                              trailing: Switch(
                                value: properties.background,
                                onChanged: (value) {
                                  setState(() {
                                    properties.background = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Alignment'.tr),
                              trailing: IntrinsicWidth(
                                child: Row(
                                  children: [
                                    Radio<MainAxisAlignment>(
                                      value: MainAxisAlignment.center,
                                      groupValue: properties.alignment,
                                      onChanged: (value) {
                                        setState(() {
                                          properties.alignment = value!;
                                        });
                                      },
                                    ),
                                    Text('Center'.tr),
                                    Radio<MainAxisAlignment>(
                                      value: MainAxisAlignment.start,
                                      groupValue: properties.alignment,
                                      onChanged: (value) {
                                        setState(() {
                                          properties.alignment = value!;
                                        });
                                      },
                                    ),
                                    Text('Start'.tr),
                                    Radio<MainAxisAlignment>(
                                      value: MainAxisAlignment.end,
                                      groupValue: properties.alignment,
                                      onChanged: (value) {
                                        setState(() {
                                          properties.alignment = value!;
                                        });
                                      },
                                    ),
                                    Text('End'.tr),
                                  ],
                                ),
                              ),
                            ),
                            ListTile(
                              title: Text('Trigger immediately'.tr),
                              trailing: Switch(
                                value: properties.immediately,
                                onChanged: (value) {
                                  setState(() {
                                    properties.immediately = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Infinite'.tr),
                              trailing: Switch(
                                value: properties.infinite,
                                onChanged: (value) {
                                  setState(() {
                                    properties.infinite = value;
                                    if (value && properties.clamping) {
                                      properties.clamping = false;
                                    }
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Message'.tr),
                              trailing: Switch(
                                value: properties.message,
                                onChanged: (value) {
                                  setState(() {
                                    properties.message = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Text'.tr),
                              trailing: Switch(
                                value: properties.text,
                                onChanged: (value) {
                                  setState(() {
                                    properties.text = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    isExpanded: _expandedIndex == i,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
