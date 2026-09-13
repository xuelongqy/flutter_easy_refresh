import 'package:example/page/more/theme_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late ThemeController controller;

  setUp(() {
    Get.testMode = true;
    controller = Get.put(ThemeController());
  });

  tearDown(Get.reset);

  test('defaults to system mode with green seed', () {
    expect(controller.mode.value, ThemeMode.system);
    expect(controller.seedColor.value, Colors.green);
    expect(controller.theme.value, 'System');
  });

  test('apply with a mode entry only changes the mode', () {
    controller.apply(const ThemeModel(name: 'Dark', mode: ThemeMode.dark));

    expect(controller.mode.value, ThemeMode.dark);
    expect(controller.seedColor.value, Colors.green);
    expect(controller.theme.value, 'Dark');
  });

  test('apply with a color entry only changes the seed color', () {
    controller.apply(const ThemeModel(name: 'Dark', mode: ThemeMode.dark));
    controller.apply(const ThemeModel(name: 'Blue', color: Colors.blue));

    expect(controller.mode.value, ThemeMode.dark);
    expect(controller.seedColor.value, Colors.blue);
    expect(controller.theme.value, 'Blue');
  });

  test('resolve follows platform brightness in system mode', () {
    expect(controller.resolve(Brightness.light).brightness, Brightness.light);
    expect(controller.resolve(Brightness.dark).brightness, Brightness.dark);
  });

  test('resolve ignores platform brightness in explicit modes', () {
    controller.mode.value = ThemeMode.light;
    expect(controller.resolve(Brightness.dark).brightness, Brightness.light);

    controller.mode.value = ThemeMode.dark;
    expect(controller.resolve(Brightness.light).brightness, Brightness.dark);
  });

  test('resolve derives the color scheme from the seed color', () {
    controller.seedColor.value = Colors.red;
    final expected = ColorScheme.fromSeed(seedColor: Colors.red);

    expect(
      controller.resolve(Brightness.light).colorScheme.primary,
      expected.primary,
    );
  });
}
