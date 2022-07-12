# Skating Indicator on EasyRefresh.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Pub](https://img.shields.io/pub/v/easy_refresh_skating](https://pub.flutter-io.cn/packages/easy_refresh_skating)

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/#/style/skating)
Animation from [Pull-to-refresh Animation Example](https://rive.app/community/2233-4412-pull-to-refresh-animation-example)

## Features

SkatingHeader and SkatingFooter.

## Getting started

```
dependencies:
  flutter_easyre_fresh: version
  easy_refresh_skating: version
```

## Usage

```dart
EasyRefresh(
  header: SkatingHeader(),
  footer: SkatingFooter(),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView(),
)
```
