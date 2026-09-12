import 'package:example/config/routes.dart';
import 'package:example/l10n/translations.dart';
import 'package:example/page/home.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:material_ui/material_ui.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as sdk_l10n;
import 'package:get/get.dart';
import 'package:rive/rive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const _mobileWidthThreshold = 500;
  static const _mobileWidth = 420.0;
  static const _mobileHeight = 900.0;

  final _appKey = GlobalKey();

  bool _hasFrame = false;

  bool get _checkSize => !GetPlatform.isMobile || GetPlatform.isWeb;

  bool _mobileStyle = true;

  @override
  void initState() {
    EasyRefresh.defaultHeaderBuilder = () => ClassicHeader(
      dragText: 'Pull to refresh'.tr,
      armedText: 'Release ready'.tr,
      readyText: 'Refreshing...'.tr,
      processingText: 'Refreshing...'.tr,
      processedText: 'Succeeded'.tr,
      noMoreText: 'No more'.tr,
      failedText: 'Failed'.tr,
      messageText: 'Last updated at %T'.tr,
    );
    EasyRefresh.defaultFooterBuilder = () => ClassicFooter(
      dragText: 'Pull to load'.tr,
      armedText: 'Release ready'.tr,
      readyText: 'Loading...'.tr,
      processingText: 'Loading...'.tr,
      processedText: 'Succeeded'.tr,
      noMoreText: 'No more'.tr,
      failedText: 'Failed'.tr,
      messageText: 'Last updated at %T'.tr,
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeMetrics() {
    if (_checkSize) {
      final size = Get.size;
      final hasFrame = size.width > _mobileWidthThreshold;
      if (_hasFrame != hasFrame) {
        setState(() {
          _hasFrame = hasFrame;
        });
      }
    }
  }

  Widget _buildFrame(Widget app) {
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          body: _mobileStyle
              ? Center(
                  child: Card(
                    elevation: 10,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      height: _mobileHeight,
                      width: _mobileWidth,
                      child: app,
                    ),
                  ),
                )
              : app,
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              setState(() {
                _mobileStyle = !_mobileStyle;
              });
            },
            child: Icon(_mobileStyle ? Icons.computer : Icons.phone_android),
          ).marginOnly(top: 16),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      key: _appKey,
      title: 'EasyRefresh',
      initialBinding: AppBindings(),
      translations: AppTranslations(),
      supportedLocales: AppTranslations.supportedLocales,
      locale: Get.deviceLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      localizationsDelegates: [
        ...GlobalMaterialLocalizations.delegates,
        // GetMaterialApp still hosts the SDK MaterialApp, which validates its
        // own (legacy) Material/Cupertino delegates against supportedLocales.
        sdk_l10n.GlobalMaterialLocalizations.delegate,
        sdk_l10n.GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
      initialRoute: '/',
      getPages: Routes.getPages,
      // GetMaterialApp only knows the SDK ThemeData, so the material_ui theme
      // is injected here above the Navigator.
      builder: (context, widget) {
        return Obx(() {
          final themeData = ThemeController.i.resolve(
            MediaQuery.platformBrightnessOf(context),
          );
          Widget app = widget!;
          if (_checkSize) {
            final window = View.of(context);
            final size = window.physicalSize / window.devicePixelRatio;
            if (size.width > _mobileWidthThreshold) {
              app = _buildFrame(app);
            }
          }
          return AnimatedTheme(data: themeData, child: app);
        });
      },
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
  }
}
