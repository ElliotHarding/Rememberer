import 'package:epilepsy_prevention/page_memories.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageTestResult extends StatelessWidget
{
  PageTestResult(this.m_memory, this.m_bSuccess);

  Memory m_memory;
  bool m_bSuccess;

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    markTestAsCompleted(m_memory);

    return WillPopScope(onWillPop: () async {Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories())); return true;}, child: Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: () => onHomePressed(context), child:
            const Text("Home", style: TextStyle(fontSize: 30, color: Colors.blue))
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02)
        ]),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
          Center(child:
            Text(m_bSuccess ? "Correct!" : "Wrong!", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center)
        )),

        SizedBox(width: MediaQuery.of(context).size.width, child:
          const Text("Question", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
          Text(m_memory.m_question, style: const TextStyle(fontSize: 30), textAlign: TextAlign.center)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, child:
          const Text("Answer", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
          Text(m_memory.m_answer, style: const TextStyle(fontSize: 30), textAlign: TextAlign.center)
        )
      ])
    ));
  }

  void onHomePressed(BuildContext context)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
  }

  void markTestAsCompleted(Memory memory)
  {
    for(int i = 0; i < memory.m_notifications.length; i++)
    {
      if(memory.m_notifications[i].m_notifyTime < DateTime.now().millisecondsSinceEpoch)
      {
        memory.m_notifications[i].m_bHasBeenTested = true;
      }
    }
    Database().addOrUpdateMemory(memory);
  }
}