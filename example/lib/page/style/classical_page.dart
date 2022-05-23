import 'package:example/page/more/theme.dart';
import 'package:example/widget/menu_bottom_bar.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_refresh/easy_refresh.dart';
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
        title: const Text('Classic'),
      ),
      body: EasyRefresh(
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
        ),
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count = 10;
          });
          _controller.finishRefresh();
          _controller.resetFooter();
        },
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(_count >= 20
              ? IndicatorResult.noMore
              : IndicatorResult.succeeded);
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
                title: const Text('Theme'),
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
                      Text(ThemeController.i.theme.value),
                    ],
                  ),
                ),
                onTap: () => Get.to(() => const ThemePage()),
              );
            }),
            ListTile(
              title: const Text('Direction'),
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
                    const Text('Vertical'),
                    Radio<Axis>(
                      value: Axis.horizontal,
                      groupValue: _scrollDirection,
                      onChanged: (value) {
                        setState(() {
                          _scrollDirection = value!;
                        });
                      },
                    ),
                    const Text('Horizontal'),
                  ],
                ),
              ),
            ),
            ExpansionPanelList(
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
                              title: const Text('Clamping'),
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
                              title: const Text('Background'),
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
                              title: const Text('Alignment'),
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
                                    const Text('Center'),
                                    Radio<MainAxisAlignment>(
                                      value: MainAxisAlignment.start,
                                      groupValue: properties.alignment,
                                      onChanged: (value) {
                                        setState(() {
                                          properties.alignment = value!;
                                        });
                                      },
                                    ),
                                    const Text('Start'),
                                    Radio<MainAxisAlignment>(
                                      value: MainAxisAlignment.end,
                                      groupValue: properties.alignment,
                                      onChanged: (value) {
                                        setState(() {
                                          properties.alignment = value!;
                                        });
                                      },
                                    ),
                                    const Text('End'),
                                  ],
                                ),
                              ),
                            ),
                            ListTile(
                              title: const Text('Infinite'),
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
                              title: const Text('Message'),
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
                              title: const Text('Text'),
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
  bool clamping = false;
  bool background = false;
  MainAxisAlignment alignment;
  bool message = true;
  bool text = true;
  bool infinite;

  _CIProperties({
    required this.name,
    required this.alignment,
    required this.infinite,
  });
}
