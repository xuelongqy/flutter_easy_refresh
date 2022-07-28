import 'package:example/config/routes.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/menu_bottom_bar.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';

class MaterialIndicatorPage extends StatefulWidget {
  const MaterialIndicatorPage({Key? key}) : super(key: key);

  @override
  State<MaterialIndicatorPage> createState() => _MaterialIndicatorPageState();
}

class _MaterialIndicatorPageState extends State<MaterialIndicatorPage> {
  late EasyRefreshController _controller;
  int _count = 10;
  Axis _scrollDirection = Axis.vertical;
  int _expandedIndex = -1;
  final _MIProperties _headerProperties = _MIProperties(
    name: 'Header',
  );
  final _MIProperties _footerProperties = _MIProperties(
    name: 'Footer',
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
        title: const Text('Material'),
      ),
      body: EasyRefresh(
        clipBehavior: Clip.none,
        controller: _controller,
        header: MaterialHeader(
          clamping: _headerProperties.clamping,
          showBezierBackground: _headerProperties.background,
          bezierBackgroundAnimation: _headerProperties.animation,
          bezierBackgroundBounce: _headerProperties.bounce,
          infiniteOffset: _headerProperties.infinite ? 100 : null,
          springRebound: _headerProperties.listSpring,
        ),
        footer: MaterialFooter(
          clamping: _footerProperties.clamping,
          showBezierBackground: _footerProperties.background,
          bezierBackgroundAnimation: _footerProperties.animation,
          bezierBackgroundBounce: _footerProperties.bounce,
          infiniteOffset: _footerProperties.infinite ? 100 : null,
          springRebound: _footerProperties.listSpring,
        ),
        onRefresh: () async {
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
        onLoad: () async {
          await Future.delayed(const Duration(seconds: 2));
          if (!mounted) {
            return;
          }
          setState(() {
            _count += 5;
          });
          _controller.finishLoad(
              _count >= 20 ? IndicatorResult.noMore : IndicatorResult.success);
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
                              title: Text('Animation'.tr),
                              trailing: Switch(
                                value: properties.animation,
                                onChanged: (value) {
                                  setState(() {
                                    properties.animation = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Bounce'.tr),
                              trailing: Switch(
                                value: properties.bounce,
                                onChanged: (value) {
                                  setState(() {
                                    properties.bounce = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('List Spring'.tr),
                              trailing: Switch(
                                value: properties.listSpring,
                                onChanged: (value) {
                                  setState(() {
                                    properties.listSpring = value;
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

/// Material indicator properties.
class _MIProperties {
  final String name;
  bool clamping = true;
  bool background = false;
  bool animation = false;
  bool bounce = false;
  bool infinite = false;
  bool listSpring = false;

  _MIProperties({
    required this.name,
  });
}
