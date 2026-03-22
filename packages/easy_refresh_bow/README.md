# Bow Indicator on EasyRefresh.

[![License](https://img.shields.io/badge/license-MIT-green.svg)](/LICENSE)
[![Pub](https://img.shields.io/pub/v/easy_refresh_bow)](https://pub.flutter-io.cn/packages/easy_refresh_bow)

### [Online demo](https://xuelongqy.github.io/flutter_easy_refresh/#/style/bow)
Animation from [Bow Pull to Refresh](https://github.com/phucho2306/RivePullToRefresh)

## Features

BowHeader and BowFooter.

## Getting started

```yaml
dependencies:
  easy_refresh: version
  easy_refresh_bow: version
```

## Usage

```dart
EasyRefresh(
  header: const BowHeader(),
  footer: const BowFooter(),
  onRefresh: () async {},
  onLoad: () async {},
  child: ListView(),
)
```
