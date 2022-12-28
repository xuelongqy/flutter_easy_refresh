import 'package:easy_refresh/easy_refresh.dart';
import 'package:example/config/routes.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeSwitchPage extends StatefulWidget {
  const ThemeSwitchPage({Key? key}) : super(key: key);

  @override
  State<ThemeSwitchPage> createState() => _ThemeSwitchPageState();
}

class _ThemeSwitchPageState extends State<ThemeSwitchPage> {
  final _pointerWidth = 4.0;
  final _pointerHeight = 20.0;
  final _ballSize = 40.0;
  final _currentBallSize = 50.0;
  final _ballBoxSize = 60.0;
  final _headerHeight = 100.0;
  final _count = 20;

  late final Rx<double> _positionRx;

  final _colors = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.pink,
  ];

  final _currentColorRx = Colors.green.obs;

  @override
  void initState() {
    super.initState();
    _positionRx = (Get.width / 2).obs;
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return Scaffold(
      body: EasyRefresh(
        onRefresh: () {
          final themeData = ThemeModel.generateTheme(
            brightness: Get.theme.brightness,
            colorSchemeSeed: _currentColorRx.value,
          );
          Get.changeTheme(themeData);
          // ??
          Get.changeThemeMode(ThemeMode.light);
        },
        header: BuilderHeader(
          triggerOffset: _headerHeight,
          maxOverOffset: _headerHeight,
          clamping: true,
          position: IndicatorPosition.locator,
          processedDuration: Duration.zero,
          builder: (ctx, state) {
            double height = state.safeOffset + _headerHeight;
            height = (height - 20) + 20 * (state.offset / height);
            return Stack(
              children: [
                Container(
                  color: themeData.colorScheme.inverseSurface,
                  width: double.infinity,
                  height: state.offset,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: height,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Obx(() {
                              return Positioned(
                                left: (Get.width - _positionRx.value) -
                                    (_ballBoxSize / 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final color in _colors)
                                      Container(
                                        alignment: Alignment.center,
                                        width: _ballBoxSize,
                                        height: _ballBoxSize,
                                        child: Obx(() {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 400),
                                            curve: Curves.easeInOutBack,
                                            width:
                                                _currentColorRx.value == color
                                                    ? _currentBallSize
                                                    : _ballSize,
                                            height:
                                                _currentColorRx.value == color
                                                    ? _currentBallSize
                                                    : _ballSize,
                                            decoration: BoxDecoration(
                                              color:
                                                  _currentColorRx.value == color
                                                      ? color
                                                      : null,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      _currentColorRx.value ==
                                                              color
                                                          ? _currentBallSize / 2
                                                          : _ballSize / 2)),
                                              border:
                                                  _currentColorRx.value == color
                                                      ? null
                                                      : Border.all(
                                                          width: 2,
                                                          color: color,
                                                        ),
                                            ),
                                          );
                                        }),
                                      ),
                                  ],
                                ),
                              );
                            }),
                            Obx(() {
                              return Positioned(
                                bottom: 0,
                                left: _positionRx.value - (_pointerWidth / 2),
                                child: Container(
                                  width: _pointerWidth,
                                  height: _pointerHeight,
                                  decoration: BoxDecoration(
                                      color: themeData
                                          .colorScheme.onInverseSurface,
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              _pointerWidth / 2))),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        child: Listener(
          onPointerMove: (event) {
            double position = _positionRx.value + event.delta.dx;
            double min = Get.width / 2;
            double max =
                Get.width / 2 + ((_colors.length - 1) * _ballBoxSize / 2);
            if (position < min) {
              position = min;
            }
            if (position > max) {
              position = max;
            }
            _positionRx.value = position;
            double offset = position - min;
            if (offset < _ballBoxSize / 4) {
              _currentColorRx.value = _colors.first;
            } else if (offset >= max - (_ballBoxSize / 4)) {
              _currentColorRx.value = _colors.last;
            } else {
              _currentColorRx.value = _colors[
                  ((offset - _ballBoxSize / 4) / (_ballBoxSize / 2)).ceil()];
            }
          },
          child: CustomScrollView(
            slivers: [
              const HeaderLocator.sliver(clearExtent: false),
              SliverAppBar(
                backgroundColor: themeData.colorScheme.primary,
                foregroundColor: themeData.colorScheme.onPrimary,
                leading: BackButton(
                  color: themeData.colorScheme.onPrimary,
                ),
                title: Text('Theme switch'.tr),
                pinned: true,
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return const SkeletonItem();
                  },
                  childCount: _count,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Theme'.tr),
        icon: const Icon(Icons.color_lens),
        onPressed: () => Get.toNamed(Routes.theme),
      ),
    );
  }
}
