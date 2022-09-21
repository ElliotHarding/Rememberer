import 'package:epilepsy_prevention/page_memories.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageTestResult extends StatelessWidget
{
  PageTestResult(this.m_memory, this.m_bSuccess, this.m_context);

  Memory m_memory;
  bool m_bSuccess;

  BuildContext m_context;

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

    m_context = context;

    return WillPopScope(onWillPop: onBackPressed, child: Scaffold(
      body: Column(children: <Widget>[

        const Spacer(),

        Text(m_bSuccess ? "Correct!" : "Wrong!", style: const TextStyle(fontSize: 30), textAlign: TextAlign.left),

        const Spacer(),

        Text(m_memory.m_question, style: const TextStyle(fontSize: 30), textAlign: TextAlign.center),

        const Spacer(),

        Text(m_memory.m_answer, style: const TextStyle(fontSize: 30), textAlign: TextAlign.left),

        const Spacer(),

        TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
        }, child: const Text("Home")),
      ]
      )
    ));
  }

  Future<bool> onBackPressed() async
  {
    Navigator.push(m_context, MaterialPageRoute(builder: (context) => const PageMemories()));
    return true;
  }
}