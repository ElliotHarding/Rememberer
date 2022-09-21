import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/page_settings.dart';
import 'package:epilepsy_prevention/page_upcommingNotifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memories.dart';
import 'package:epilepsy_prevention/page_test.dart';

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

    Notifications.m_selectedNotificationSubject.stream.listen((String? memoryKey) async {
      if(memoryKey != null) {
        var database = Database();
        int? keyValue = int.tryParse(memoryKey);
        if(keyValue != null)
        {
          Memory? mem = database.getMemoryWithId(keyValue);
          if (mem != null) {
            Notifications.m_selectedNotificationSubject.add(null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(mem)));
          }
        }
      }
    });

    return Scaffold(
      body: Column(children: [

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * .5, child: GridView.count(crossAxisCount: 2,
            children: <Widget>[
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
              }, child: const Text("New Memory")),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
              }, child: const Text("View Memories")),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSettings()));
              }, child: const Text("Settings")),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PageUpcommingNotifications()));
              }, child: const Text("Notifications"))
            ])
        ),

        const Spacer()
      ],)
    );
  }
}