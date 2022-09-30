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

    return WillPopScope(onWillPop: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); return true;}, child: Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

        Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: () => gotoAddNewMemory(context), child:
            const Text("Add New Memory", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center)
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.02)
        ]),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child:
          SizedBox(width: MediaQuery.of(context).size.width * 0.8, child:
            const Text("Memories", style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.left)
        )),

        ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: m_memoryWidgets),
      ])
      )
    );
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
            SizedBox(width: MediaQuery.of(context).size.width * 0.7, child:
              TextButton( onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
                setState(() {
                  m_memoryWidgets = getMemoryWidgets(context);
                });
                }, child: Text(memory.m_question, style: const TextStyle(fontSize: 30.0, color: Colors.blue))
              )
            ),

            SizedBox(width: MediaQuery.of(context).size.width * 0.3, child:
              TextButton(onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory)));
              }, child:
                const Text("Test", style: TextStyle(fontSize: 30.0, color: Colors.blue))
              )
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.1)
          ],
        ));
      }
    }
    return widgets;
  }

  void gotoAddNewMemory(BuildContext context) async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
    setState(() {
      m_memoryWidgets = getMemoryWidgets(context);
    });
  }
}