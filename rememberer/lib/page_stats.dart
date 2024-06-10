import 'package:flutter/material.dart';
import 'display.dart';
import 'memory.dart';
import 'notifications.dart';

class PageStats extends StatefulWidget
{
  PageStats({required this.m_memory, Key? key}) : super(key: key);

  Memory m_memory;

  @override
  State<PageStats> createState() => PageStatsState();
}

class PageStatsState extends State<PageStats> {

  void initState() {

  }

  Widget build(BuildContext context) {
    Notifications.setupNotificationActionListener(context);

    final double verticalSpacer = MediaQuery.of(context).size.height * 0.05;
    final double headerLeftMargin = MediaQuery.of(context).size.width * 0.05;

    return Scaffold(body: ListView(shrinkWrap: true, children: <Widget>[

      Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin, verticalSpacer, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
        Text("Stats", style: Display.titleTextStyle, textAlign: TextAlign.left),
      )),

      Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin * 2, verticalSpacer, 0, 0), child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Failed tests: 0", style: Display.largeTextStyle, textAlign: TextAlign.left),
          Text("Passed tests: 0", style: Display.largeTextStyle, textAlign: TextAlign.left),
          Text("Failed/Succeeded ratio: 0.0", style: Display.largeTextStyle, textAlign: TextAlign.left),
          Text("Due tests: 0", style: Display.largeTextStyle, textAlign: TextAlign.left),
        ],)
      ),

      Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
        const Spacer(),

        TextButton(onPressed: () => onBack(), child: Text("Back", style: Display.miniNavButtonTextStyle)),

        const Spacer(),

        TextButton(onPressed: () => onClearStats(), child: Text("Clear Stats", style: Display.miniNavButtonTextStyle)),

        const Spacer()
      ]),

      SizedBox(height: verticalSpacer)
    ])
    );
  }

  void onBack()
  {
    Navigator.pop(context);
  }

  void onClearStats()
  {
    Navigator.pop(context);
  }
}