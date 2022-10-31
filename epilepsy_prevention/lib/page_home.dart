import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/page_settings.dart';
import 'package:epilepsy_prevention/page_upcomingNotifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memories.dart';
import 'package:epilepsy_prevention/page_overdueTests.dart';

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
      body:  SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: ListView(
          children: <Widget>[
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton( onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
            }, child: const Text("New Memory", style: TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
            }, child: const Text("Memories", style: TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageOverdueTests()));
            }, child: const Text("Overdue Tests", style: TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageUpcomingNotifications()));
            }, child: const Text("Notifications", style: TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: screenHeight * 0.2, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSettings()));
            }, child: const Text("Settings", style: TextStyle(fontSize: 30.0, color: Colors.blue))))
          ])
      )
    );
  }
}