library easy_refresh;

import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' as physics;
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:easy_refresh/src/painter/paths_painter.dart';

part 'src/easy_refresh.dart';
part 'src/physics/scroll_physics.dart';
part 'src/notifier/indicator_notifier.dart';
part 'src/behavior/scroll_behavior.dart';
part 'src/indicator/indicator.dart';
part 'src/indicator/header/header.dart';
part 'src/indicator/header/header_locator.dart';
part 'src/indicator/footer/footer.dart';
part 'src/indicator/footer/footer_locator.dart';
part 'src/controller/controller.dart';
part 'src/styles/classic/header/classic_header.dart';
part 'src/styles/classic/footer/classic_footer.dart';
part 'src/styles/classic/classic_indicator.dart';
part 'src/styles/material/material_indicator.dart';
part 'src/styles/material/header/material_header.dart';
part 'src/styles/material/footer/material_footer.dart';
part 'src/styles/bezier/bezier_background.dart';
part 'src/styles/bezier/bezier_indicator.dart';
part 'src/styles/bezier/bezier_circle_indicator.dart';
part 'src/styles/bezier/spin/hour_glass.dart';
part 'src/styles/bezier/header/bezier_header.dart';
part 'src/styles/bezier/header/bezier_circle_header.dart';
part 'src/styles/bezier/footer/bezier_footer.dart';
part 'src/styles/phoenix/phoenix_indicator.dart';
part 'src/styles/phoenix/header/phoenix_header.dart';
part 'src/styles/phoenix/footer/phoenix_footer.dart';
part 'src/styles/taurus/taurus_indicator.dart';
part 'src/styles/taurus/header/taurus_header.dart';
part 'src/styles/taurus/footer/taurus_footer.dart';
part 'src/styles/delivery/delivery_indicator.dart';
part 'src/styles/delivery/header/delivery_header.dart';
part 'src/styles/delivery/footer/delivery_footer.dart';
part 'src/styles/cupertino/cupertino_indicator.dart';
part 'src/styles/cupertino/cupertino_activity_indicator.dart';
part 'src/styles/cupertino/header/cupertino_header.dart';
part 'src/styles/cupertino/footer/cupertino_footer.dart';

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;
