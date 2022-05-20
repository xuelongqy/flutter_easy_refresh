import 'dart:io';

import 'package:example/widget/list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  static ThemeController get i => Get.find();

  final theme = 'System'.obs;
}

class ThemePage extends StatefulWidget {
  const ThemePage({Key? key}) : super(key: key);

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String theme = ThemeController.i.theme.value;
      return Scaffold(
        appBar: AppBar(
          title: const Text('Theme'),
        ),
        body: ListView(
          children: [
            ListItem(
              title: 'System',
              icon: Platform.isAndroid || Platform.isIOS ? Icons.phone_android : Icons.computer,
              divider: false,
              selected: theme == 'System',
              onTap: () {
                ThemeController.i.theme.value = 'System';
                Get.changeThemeMode(ThemeMode.system);
              },
            ),
            ListItem(
              title: 'Light',
              icon: Icons.light_mode,
              divider: false,
              selected: theme == 'Light',
              onTap: () {
                ThemeController.i.theme.value = 'Light';
                Get.changeThemeMode(ThemeMode.light);
              },
            ),
            ListItem(
              title: 'Dark',
              icon: Icons.dark_mode,
              divider: false,
              selected: theme == 'Dark',
              onTap: () {
                ThemeController.i.theme.value = 'Dark';
                Get.changeThemeMode(ThemeMode.dark);
              },
            ),
          ],
        ),
      );
    });
  }
}
