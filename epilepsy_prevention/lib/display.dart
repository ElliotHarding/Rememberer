import 'dart:ui';
import 'package:flutter/material.dart';

class Display {
  static final Display _m_display = Display._internal();

  //Accessible text sizes (loaded after init)
  static double smallTextSize = 0;
  static double normalTextSize = 0;
  static double largeTextSize = 0;
  static double menuPageTextSize = 0;

  //Accessible text styles (loaded after init)
  static TextStyle graphIndexStyle = TextStyle();
  static TextStyle listItemTextStyle = TextStyle();
  static TextStyle listItemTextStyleBlack = TextStyle();
  static TextStyle normalTextStyle = TextStyle();
  static TextStyle largeTextStyle = TextStyle();
  static TextStyle largeTextStyleBlack = TextStyle();
  static TextStyle titleTextStyle = TextStyle();
  static TextStyle miniNavButtonTextStyle = TextStyle();

  //Accessible text colors
  static MaterialColor normalTextColor = Colors.blue;

  factory Display()
  {
    return _m_display;
  }

  Display._internal();

  void init()
  {
    var screenWidth = window.physicalSize.width / window.devicePixelRatio;
    var leftPadding = window.padding.left / window.devicePixelRatio;
    var rightPadding = window.padding.right / window.devicePixelRatio;

    var appScreenWidth = screenWidth - leftPadding - rightPadding;

    final double unitWidthValue = appScreenWidth * 0.01;
    smallTextSize = 3 * unitWidthValue;
    normalTextSize = 6 * unitWidthValue;
    largeTextSize = 7 * unitWidthValue;
    menuPageTextSize = 10 * unitWidthValue;

    listItemTextStyle = TextStyle(fontSize: normalTextSize, color: normalTextColor);
    listItemTextStyleBlack = TextStyle(fontSize: normalTextSize, color: Colors.black);

    normalTextStyle = TextStyle(fontSize: normalTextSize, color: normalTextColor);
    largeTextStyle = TextStyle(fontSize: largeTextSize, color: normalTextColor);
    largeTextStyleBlack = TextStyle(fontSize: largeTextSize, color: Colors.black);

    graphIndexStyle = TextStyle(fontSize: smallTextSize, color: Colors.blue);

    titleTextStyle = TextStyle(fontSize: largeTextSize, fontWeight: FontWeight.bold, color: Colors.blue);

    miniNavButtonTextStyle = TextStyle(fontSize: normalTextSize, color: Colors.blue);
  }
}