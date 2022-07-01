import 'package:example/l10n/translations.dart';
import 'package:example/page/home.dart';
import 'package:example/page/more/theme_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easy_refresh/easy_refresh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'EasyRefresh',
      theme: ThemeModel.light,
      darkTheme: ThemeModel.dark,
      initialBinding: AppBindings(),
      translations: AppTranslations(),
      supportedLocales: AppTranslations.supportedLocales,
      locale: Get.deviceLocale,
      fallbackLocale: AppTranslations.fallbackLocale,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      home: const HomePage(),
    );
  }
}

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
  }
}
