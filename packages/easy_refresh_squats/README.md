# Squats Indicator on EasyRefresh.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Pub](https://img.shields.io/pub/v/easy_refresh_squats)](https://pub.flutter-io.cn/packages/easy_refresh_squats)

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/#/style/squats)
Animation from [Lumberjack Squats](https://rive.app/community/980-1894-lumberjack-squats)

## Features

SquatsHeader and SquatsFooter.

## Getting started

Requires Flutter >=3.47 and Dart ^3.13.

```yaml
dependencies:
  flutter:
    sdk: flutter
  easy_refresh: ^4.0.0
  easy_refresh_squats: ^2.0.0
  material_ui: ^1.2.0
  rive: ^0.14.11
```

## Usage

Initialize Rive before runApp. Assets are bundled with the package; no app asset declarations are needed. These indicators support vertical scrolling.

```dart
import 'package:easy_refresh/easy_refresh.dart';
import 'package:easy_refresh_squats/easy_refresh_squats.dart';
import 'package:material_ui/material_ui.dart';
import 'package:rive/rive.dart' show RiveNative;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RiveNative.init();
  runApp(const MaterialApp(home: StyleExample()));
}

class StyleExample extends StatefulWidget {
  const StyleExample({super.key});

  @override
  State<StyleExample> createState() => _StyleExampleState();
}

class _StyleExampleState extends State<StyleExample> {
  int _count = 30;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Squats indicators')),
    body: EasyRefresh(
      header: const SquatsHeader(),
      footer: const SquatsFooter(),
      onRefresh: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return IndicatorResult.fail;
        setState(() => _count = 30);
        return IndicatorResult.success;
      },
      onLoad: () async {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (!mounted) return IndicatorResult.fail;
        if (_count < 90) setState(() => _count += 30);
        return _count >= 90 ? IndicatorResult.noMore : IndicatorResult.success;
      },
      child: ListView.builder(
        itemCount: _count,
        itemBuilder: (_, index) => ListTile(title: Text('Item $index')),
      ),
    ),
  );
}
```

## AI agent skill

[Usage guide](skills/easy-refresh-squats-usage/SKILL.md) covers supported parameters and limitations.
Run in your app after adding the dependency:

```sh
dart run skills@ get
```
