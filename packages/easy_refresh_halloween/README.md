# Halloween Indicator on EasyRefresh.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Pub](https://img.shields.io/pub/v/easy_refresh_halloween)](https://pub.flutter-io.cn/packages/easy_refresh_halloween)

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/#/style/halloween)
Animation from [Pull to refresh halloween](https://rive.app/community/68-95-pull-to-refresh-halloween)

## Features

HalloweenHeader and HalloweenFooter.

## Getting started

```
dependencies:
  flutter_easyre_fresh: version
  easy_refresh_halloween: version
```

## Usage

```dart
EasyRefresh(
  header: HalloweenHeader(),
  footer: HalloweenFooter(),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView(),
)
```
