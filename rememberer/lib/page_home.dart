import 'notifications.dart';
import 'page_settings.dart';
import 'page_upcomingNotifications.dart';
import 'package:flutter/material.dart';
import 'page_memory.dart';
import 'memory.dart';
import 'page_memories.dart';
import 'page_overdueTests.dart';
import 'display.dart';

class PageHome extends StatefulWidget
{
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome>
{
  @override
  Widget build(BuildContext context) {

    Notifications.setupNotificationActionListener(context);

    final double screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top - MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      body:  SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: ListView(physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton( onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
            }, child: Text("New Memory", style: Display.menuPageTextStyle))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
            }, child: Text("Memories", style: Display.menuPageTextStyle))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageOverdueTests()));
            }, child: Text("Overdue Tests", style: Display.menuPageTextStyle))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageUpcomingNotifications()));
            }, child: Text("Notifications", style: Display.menuPageTextStyle))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSettings()));
            }, child: Text("Settings", style: Display.menuPageTextStyle)))
          ])
      )
    );
  }
}