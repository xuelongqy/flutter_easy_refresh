library easy_paging;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' as physics;

import 'easy_refresh.dart';

part 'src/easy_paging.dart';

/// This allows a value of type T or T?
/// to be treated as a value of type T?.
///
/// We use this so that APIs that have become
/// non-nullable can still be used with `!` and `?`
/// to support older versions of the API as well.
T? _ambiguate<T>(T? value) => value;
