import 'package:epilepsy_prevention/page_memories.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageTestResult extends StatelessWidget
{
  PageTestResult(this.m_memory, this.m_bSuccess);

  Memory m_memory;
  bool m_bSuccess;

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

    return WillPopScope(onWillPop: () async {Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories())); return true;}, child: Scaffold(body:
    Column(children: <Widget>[

      const Spacer(),

      SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
        Text(m_bSuccess ? "Correct!" : "Wrong!", style: const TextStyle(fontSize: 30), textAlign: TextAlign.center)
      ),

      SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.1, child:
        const Text("Question", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center)
      ),

      SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.1, child:
        Text(m_memory.m_question, style: const TextStyle(fontSize: 30), textAlign: TextAlign.center)
      ),

      const Spacer(),

      SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.1, child:
        const Text("Answer", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center)
      ),

      SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.1, child:
        Text(m_memory.m_answer, style: const TextStyle(fontSize: 30), textAlign: TextAlign.center)
      ),

      const Spacer(),

      SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.2, child:
        TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
        }, child: const Text("Home", style: TextStyle(fontSize: 30, color: Colors.blue))),
      )
    ])
    ));
  }
}