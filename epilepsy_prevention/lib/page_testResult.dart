import 'package:epilepsy_prevention/display.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageTestResult extends StatelessWidget
{
  PageTestResult(this.m_memory, this.m_bSuccess, this.m_returnWidget);

  StatefulWidget m_returnWidget;
  Memory m_memory;
  bool m_bSuccess;

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    markTestAsCompleted(m_memory);

    return WillPopScope(onWillPop: () async {Navigator.push(context, MaterialPageRoute(builder: (context) => m_returnWidget)); return true;}, child: Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02), child: Align(alignment: Alignment.centerLeft, child:
          TextButton(onPressed: () => onHomePressed(context), child:
            Text("<- Home", style: Display.miniNavButtonTextStyle)
        ))),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
          Center(child:
            Text(m_bSuccess ? "Correct!" : "Wrong!", style: Display.largeTextStyle, textAlign: TextAlign.center)
        )),

        SizedBox(width: MediaQuery.of(context).size.width, child:
          Text("Question", style: Display.largeTextStyle, textAlign: TextAlign.center)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
          Text(m_memory.m_question, style: Display.largeTextStyleBlack, textAlign: TextAlign.center)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, child:
          Text("Answer", style: Display.largeTextStyle, textAlign: TextAlign.center)
        ),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.25, child:
          Text(m_memory.m_answer, style: Display.largeTextStyleBlack, textAlign: TextAlign.center)
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