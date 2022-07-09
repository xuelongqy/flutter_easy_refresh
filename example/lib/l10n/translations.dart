import 'package:example/l10n/translations/en.dart';
import 'package:example/l10n/translations/zh_cn.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'zh_CN': zhCN,
      };

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh', 'CN'),
  ];

  static const fallbackLocale = Locale('en');
}
