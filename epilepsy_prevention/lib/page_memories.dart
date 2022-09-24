import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageMemories extends StatefulWidget
{
  PageMemories({Key? key}) : super(key: key);

   @override
  State<PageMemories> createState() => PageMemoriesState();
}

class PageMemoriesState extends State<PageMemories>
{
  List<Widget> m_memoryWidgets = [];

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    m_memoryWidgets = getMemoryWidgets(context);

    return WillPopScope(onWillPop: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); return true;}, child: Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>
        [
        SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.15, child:
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Spacer(),

            TextButton(onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
              setState(() {
                m_memoryWidgets = getMemoryWidgets(context);
              });
              },
                child: const Text("Add New Memory", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)
            ),

            const Spacer()
          ],)
        ),

        SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.1, child:
          const Text("Memories", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.75, child: ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: m_memoryWidgets)),
        ]
      )
    ));
   }

  List<Widget> getMemoryWidgets(BuildContext context)
  {
    List<Widget> widgets = <Widget>[];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.7, height: MediaQuery.of(context).size.height * 0.1, child: TextButton( onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
              setState(() {
                m_memoryWidgets = getMemoryWidgets(context);
              });
            }, child: Text(memory.m_question, style: const TextStyle(fontSize: 30.0, color: Colors.blue)))),

            SizedBox(width: MediaQuery.of(context).size.width * 0.3, height: MediaQuery.of(context).size.height * 0.1, child: TextButton( onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory)));
            }, child: const Text("Test", style: TextStyle(fontSize: 30.0, color: Colors.blue))))
          ],
        ));
      }
    }
    return widgets;
  }
}