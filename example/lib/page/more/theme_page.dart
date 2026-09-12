import 'package:example/widget/list_item.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

class ThemeModel {
  final String name;
  final Color? color;
  final ThemeMode? mode;
  final IconData? icon;

  const ThemeModel({required this.name, this.color, this.mode, this.icon});

  static ThemeData generateTheme({
    required Brightness brightness,
    required Color colorSchemeSeed,
  }) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorSchemeSeed: colorSchemeSeed,
    );
  }

  static final themes = [
    ThemeModel(
      name: 'System',
      mode: ThemeMode.system,
      icon: GetPlatform.isMobile ? Icons.phone_android : Icons.computer,
    ),
    const ThemeModel(
      name: 'Light',
      mode: ThemeMode.light,
      icon: Icons.light_mode,
    ),
    const ThemeModel(name: 'Dark', mode: ThemeMode.dark, icon: Icons.dark_mode),
    const ThemeModel(name: 'Blue', color: Colors.blue),
    const ThemeModel(name: 'Red', color: Colors.red),
    const ThemeModel(name: 'Pink', color: Colors.pink),
    const ThemeModel(name: 'Purple', color: Colors.purple),
    const ThemeModel(name: 'DeepPurple', color: Colors.deepPurple),
    const ThemeModel(name: 'Indigo', color: Colors.indigo),
    const ThemeModel(name: 'LightBlue', color: Colors.lightBlue),
    const ThemeModel(name: 'Cyan', color: Colors.cyan),
    const ThemeModel(name: 'Teal', color: Colors.teal),
    const ThemeModel(name: 'LightGreen', color: Colors.lightGreen),
    const ThemeModel(name: 'Lime', color: Colors.lime),
    const ThemeModel(name: 'Yellow', color: Colors.yellow),
    const ThemeModel(name: 'Amber', color: Colors.amber),
    const ThemeModel(name: 'Orange', color: Colors.orange),
    const ThemeModel(name: 'DeepOrange', color: Colors.deepOrange),
    const ThemeModel(name: 'Brown', color: Colors.brown),
    const ThemeModel(name: 'Grey', color: Colors.grey),
    const ThemeModel(name: 'BlueGrey', color: Colors.blueGrey),
  ];
}

class ThemeController extends GetxController {
  static ThemeController get i => Get.find();

  final theme = 'System'.obs;
  final mode = ThemeMode.system.obs;
  final seedColor = Rx<Color>(Colors.green);

  ThemeModel get themeModel => ThemeModel.themes.firstWhere(
    (element) => element.name == theme.value,
    orElse: () => ThemeModel.themes.first,
  );

  /// Mode entries switch [mode]; color entries switch [seedColor].
  void apply(ThemeModel model) {
    if (model.mode != null) {
      mode.value = model.mode!;
    } else if (model.color != null) {
      seedColor.value = model.color!;
    }
    theme.value = model.name;
  }

  ThemeData resolve(Brightness platformBrightness) {
    final brightness = switch (mode.value) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformBrightness,
    };
    return ThemeModel.generateTheme(
      brightness: brightness,
      colorSchemeSeed: seedColor.value,
    );
  }
}

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String theme = ThemeController.i.theme.value;
      return Scaffold(
        appBar: AppBar(title: Text('Theme'.tr)),
        body: ListView(
          children: [
            for (final model in ThemeModel.themes)
              ListItem(
                title: model.name.tr,
                leading: model.icon == null
                    ? Container(
                        height: 24,
                        width: 24,
                        decoration: BoxDecoration(
                          color: model.color,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(12),
                          ),
                        ),
                      )
                    : Icon(model.icon),
                divider: false,
                selected: theme == model.name,
                onTap: () => ThemeController.i.apply(model),
              ),
          ],
        ),
      );
    });
  }
}
