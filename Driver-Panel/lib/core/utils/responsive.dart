import 'package:flutter/material.dart';

/// Phone-only layout helpers. This app targets mobile phones only.
class Responsive {
  Responsive._();

  static const double phoneWidth = 390;

  static bool isMobile(BuildContext context) => true;

  static bool isTablet(BuildContext context) => false;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;

  static double height(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static EdgeInsets pagePadding(BuildContext context) =>
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16);

  static double fontScale(BuildContext context) => 1.0;
}
