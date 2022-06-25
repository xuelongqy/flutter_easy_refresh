import 'package:example/page/more/theme_page.dart';
import 'package:example/widget/menu_bottom_bar.dart';
import 'package:example/widget/skeleton_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class BezierPage extends StatefulWidget {
  const BezierPage({Key? key}) : super(key: key);

  @override
  State<BezierPage> createState() => _BezierPageState();
}

class _BezierPageState extends State<BezierPage> {
  late EasyRefreshController _controller;
  int _count = 10;
  Axis _scrollDirection = Axis.vertical;
  int _expandedIndex = -1;
  final _BIProperties _headerProperties = _BIProperties(
    name: 'Header',
  );
  final _BIProperties _footerProperties = _BIProperties(
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

  static const List<String> _spins = [
    'HourGlass',
    'RotatingPlain',
    'DoubleBounce',
    'Wave',
    'WanderingCubes',
    'FadingFour',
    'FadingCube',
    'Pulse',
    'ChasingDots',
    'ThreeBounce',
    'Circle',
    'CubeGrid',
    'FadingCircle',
    'RotatingCircle',
    'FoldingCube',
    'PumpingHeart',
    'PouringHourGlass',
    'PouringHourGlassRefined',
    'FadingGrid',
    'Ring',
    'Ripple',
    'SpinningCircle',
    'SpinningLines',
    'SquareCircle',
    'DualRing',
    'PianoWave',
    'DancingSquare',
    'ThreeInOut',
  ];

  Widget? _spinWidget(String spin) {
    switch (spin) {
      case 'RotatingPlain':
        return const SpinKitRotatingPlain(
          size: 32,
          color: Colors.white,
        );
      case 'DoubleBounce':
        return const SpinKitDoubleBounce(
          size: 32,
          color: Colors.white,
        );
      case 'Wave':
        return const SpinKitWave(
          size: 32,
          color: Colors.white,
        );
      case 'WanderingCubes':
        return const SpinKitWanderingCubes(
          size: 32,
          color: Colors.white,
        );
      case 'FadingFour':
        return const SpinKitFadingFour(
          size: 32,
          color: Colors.white,
        );
      case 'FadingCube':
        return const SpinKitFadingCube(
          size: 32,
          color: Colors.white,
        );
      case 'Pulse':
        return const SpinKitPulse(
          size: 32,
          color: Colors.white,
        );
      case 'ChasingDots':
        return const SpinKitChasingDots(
          size: 32,
          color: Colors.white,
        );
      case 'ThreeBounce':
        return const SpinKitThreeBounce(
          size: 32,
          color: Colors.white,
        );
      case 'Circle':
        return const SpinKitCircle(
          size: 32,
          color: Colors.white,
        );
      case 'CubeGrid':
        return const SpinKitCubeGrid(
          size: 32,
          color: Colors.white,
        );
      case 'FadingCircle':
        return const SpinKitFadingCircle(
          size: 32,
          color: Colors.white,
        );
      case 'RotatingCircle':
        return const SpinKitRotatingCircle(
          size: 32,
          color: Colors.white,
        );
      case 'FoldingCube':
        return const SpinKitFoldingCube(
          size: 32,
          color: Colors.white,
        );
      case 'PumpingHeart':
        return const SpinKitPumpingHeart(
          size: 32,
          color: Colors.white,
        );
      case 'HourGlass':
        return const SpinKitHourGlass(
          size: 32,
          color: Colors.white,
        );
      case 'PouringHourGlass':
        return const SpinKitPouringHourGlass(
          size: 32,
          color: Colors.white,
        );
      case 'PouringHourGlassRefined':
        return const SpinKitPouringHourGlassRefined(
          size: 32,
          color: Colors.white,
        );
      case 'FadingGrid':
        return const SpinKitFadingGrid(
          size: 32,
          color: Colors.white,
        );
      case 'Ring':
        return const SpinKitRing(
          size: 32,
          color: Colors.white,
        );
      case 'Ripple':
        return const SpinKitRipple(
          size: 32,
          color: Colors.white,
        );
      case 'SpinningCircle':
        return const SpinKitSpinningCircle(
          size: 32,
          color: Colors.white,
        );
      case 'SpinningLines':
        return const SpinKitSpinningLines(
          size: 32,
          color: Colors.white,
        );
      case 'SquareCircle':
        return const SpinKitSquareCircle(
          size: 32,
          color: Colors.white,
        );
      case 'DualRing':
        return const SpinKitDualRing(
          size: 32,
          color: Colors.white,
        );
      case 'PianoWave':
        return const SpinKitPianoWave(
          size: 32,
          color: Colors.white,
        );
      case 'DancingSquare':
        return const SpinKitDancingSquare(
          size: 32,
          color: Colors.white,
        );
      case 'ThreeInOut':
        return const SpinKitThreeInOut(
          size: 32,
          color: Colors.white,
        );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final propertiesItems = [_headerProperties, _footerProperties];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bezier'),
      ),
      body: EasyRefresh(
        controller: _controller,
        header: BezierHeader(
          clamping: _headerProperties.clamping,
          displayBalls: _headerProperties.displayBalls,
          spinWidget: _spinWidget(_headerProperties.spin),
        ),
        footer: BezierFooter(
          clamping: _footerProperties.clamping,
          displayBalls: _headerProperties.displayBalls,
          spinWidget: _spinWidget(_headerProperties.spin),
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
                onTap: () => Get.to(() => const ThemePage()),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text('Clamping'.tr),
                              trailing: Switch(
                                value: properties.clamping,
                                onChanged: (value) {
                                  setState(() {
                                    properties.clamping = value;
                                  });
                                },
                              ),
                            ),
                            ListTile(
                              title: Text('Display balls'.tr),
                              trailing: Switch(
                                value: properties.displayBalls,
                                onChanged: (value) {
                                  setState(() {
                                    properties.displayBalls = value;
                                  });
                                },
                              ),
                            ),
                            const ListTile(
                              title: Text('Spin'),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                children: [
                                  for (final spin in _spins)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: RawChip(
                                        label: Text(spin),
                                        onPressed: () {
                                          setState(() {
                                            properties.spin = spin;
                                          });
                                        },
                                        selected: properties.spin == spin,
                                      ),
                                    ),
                                ],
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

/// Bezier indicator properties.
class _BIProperties {
  final String name;
  bool clamping = false;
  bool displayBalls = true;
  String spin = 'HourGlass';

  _BIProperties({
    required this.name,
  });
}
