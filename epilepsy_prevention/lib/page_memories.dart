import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageMemories extends StatelessWidget
{
  PageMemories({super.key});

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

    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>
        [
        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
          }, child: const FittedBox(
              fit: BoxFit.fitWidth,
              child: Text("Add new entry")
            ))
        ]
        ),

        const Spacer(),

        ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: getMemoryWidgets(context)),

        const Spacer()
        ]
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
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
            }, child: Text(memory.m_question != "" ? memory.m_question : "Error")),

            TextButton(onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory)));
            }, child: const Text("Test"))
          ],
        ));
      }
    }
    return widgets;
  }
}