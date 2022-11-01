import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Display {
  static final Display _m_display = Display._internal();

  //Accessible text sizes (loaded after init)
  double smallTextSize = 0;
  double normalTextSize = 0;
  double largeTextSize = 0;
  double menuPageTextSize = 0;

  //Accessible text styles (loaded after init)
  TextStyle normalTextStyle = TextStyle();

  //Accessible text colors
  MaterialColor normalTextColor = Colors.blue;

  factory Display()
  {
    return _m_display;
  }

  Display._internal();

  void init(BuildContext context)
  {
    final double unitWidthValue = MediaQuery.of(context).size.width * 0.01;
    smallTextSize = 4 * unitWidthValue;
    normalTextSize = 6 * unitWidthValue;
    largeTextSize = 7 * unitWidthValue;
    menuPageTextSize = 10 * unitWidthValue;

    normalTextStyle = TextStyle(fontSize: normalTextSize, color: normalTextColor);
  }
}