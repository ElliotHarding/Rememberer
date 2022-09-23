import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageMemories extends StatefulWidget
{
  PageMemories({Key? key, required this.m_context}) : super(key: key);

  BuildContext m_context;

  @override
  State<PageMemories> createState() => PageMemoriesState();
}

class PageMemoriesState extends State<PageMemories>
{
  List<Widget> m_memoryWidgets = [];

  Widget build(BuildContext context)
  {
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

    widget.m_context = context;
    m_memoryWidgets = getMemoryWidgets(context);

    return WillPopScope(onWillPop: onBackPressed, child: Scaffold(
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

        const Spacer()
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
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.1, child: TextButton( onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
              setState(() {
                m_memoryWidgets = getMemoryWidgets(context);
              });
            }, child: Text(memory.m_question, style: const TextStyle(fontSize: 30.0, color: Colors.blue)))),

            SizedBox(width: MediaQuery.of(context).size.width * 0.5, height: MediaQuery.of(context).size.height * 0.1, child: TextButton( onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory)));
            }, child: const Text("Test", style: TextStyle(fontSize: 30.0, color: Colors.blue))))
          ],
        ));
      }
    }
    return widgets;
  }

  Future<bool> onBackPressed() async
  {
    Navigator.push(widget.m_context, MaterialPageRoute(builder: (context) => const PageHome()));
    return true;
  }
}