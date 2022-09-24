import 'package:epilepsy_prevention/page_settings.dart';
import 'package:epilepsy_prevention/page_upcommingNotifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memories.dart';
import 'package:epilepsy_prevention/page_common.dart';

class PageHome extends StatefulWidget with BasePage
{
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome>
{
  @override
  Widget build(BuildContext context) {

    BasePage.setupNotificationActionListener(context);

    return Scaffold(
      body:  SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: ListView(
          children: <Widget>[
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.25, child: TextButton( onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
            }, child: const Text("New Memory", style: const TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.25, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
            }, child: const Text("Memories", style: const TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.25, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageUpcommingNotifications()));
            }, child: const Text("Notifications", style: const TextStyle(fontSize: 30.0, color: Colors.blue)))),
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.25, child: TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSettings()));
            }, child: const Text("Settings", style: const TextStyle(fontSize: 30.0, color: Colors.blue))))
          ])
      )
    );
  }
}