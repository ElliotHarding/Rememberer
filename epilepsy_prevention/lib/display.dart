import 'dart:ui';
import 'package:flutter/material.dart';

class Display {
  static final Display _m_display = Display._internal();

  //Accessible text styles (loaded after init)
  static TextStyle graphIndexStyle = TextStyle();
  static TextStyle listItemTextStyle = TextStyle();
  static TextStyle listItemTextStyleBlack = TextStyle();
  static TextStyle normalTextStyle = TextStyle();
  static TextStyle largeTextStyle = TextStyle();
  static TextStyle largeTextStyleBlack = TextStyle();
  static TextStyle titleTextStyle = TextStyle();
  static TextStyle menuPageTextStyle = TextStyle();
  static TextStyle miniNavButtonTextStyle = TextStyle();
  static TextStyle searchOptionTextStyle = TextStyle();

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

    listItemTextStyle = TextStyle(fontSize: 3.5 * unitWidthValue, color: normalTextColor);
    listItemTextStyleBlack = TextStyle(fontSize: 3.5 * unitWidthValue, color: Colors.black);

    normalTextStyle = TextStyle(fontSize: 5 * unitWidthValue, color: normalTextColor);
    largeTextStyle = TextStyle(fontSize: 7 * unitWidthValue, color: normalTextColor);
    largeTextStyleBlack = TextStyle(fontSize: 7 * unitWidthValue, color: Colors.black);

    graphIndexStyle = TextStyle(fontSize: 3 * unitWidthValue, color: Colors.blue);

    titleTextStyle = TextStyle(fontSize: 7 * unitWidthValue, fontWeight: FontWeight.bold, color: Colors.blue);
    menuPageTextStyle = TextStyle(fontSize: 10 * unitWidthValue, color: Colors.blue);

    miniNavButtonTextStyle = TextStyle(fontSize: 6 * unitWidthValue, color: Colors.blue);

    searchOptionTextStyle = TextStyle(fontSize: 3 * unitWidthValue, color: Colors.blue);
  }
}