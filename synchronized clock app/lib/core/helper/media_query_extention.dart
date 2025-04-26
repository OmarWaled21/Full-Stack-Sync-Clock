import 'package:flutter/material.dart';

extension MediaQueryExtention on BuildContext {
  double get screenHeight => MediaQuery.sizeOf(this).height;
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get devicePixelRatio => MediaQuery.of(this).devicePixelRatio;
}
