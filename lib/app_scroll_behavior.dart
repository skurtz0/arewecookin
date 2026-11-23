import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';

/// Web/masaüstünde fare ve trackpad ile sürükleyerek kaydırmayı açar.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
