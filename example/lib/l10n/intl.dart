import 'package:example/l10n/translations/en.dart';
import 'package:example/l10n/translations/zh_CN.dart';
import 'package:get/get.dart';

class AppIntl extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': en,
        'zh_CN': zhCN,
      };
}
