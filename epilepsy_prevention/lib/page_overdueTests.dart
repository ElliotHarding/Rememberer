import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';

class PageOverdueTests extends StatefulWidget
{
  const PageOverdueTests({Key? key}) : super(key: key);

  @override
  State<PageOverdueTests> createState() => PageOverdueTestsState();
}

class PageOverdueTestsState extends State<PageOverdueTests>
{
  List<Widget> m_overdueTestWidgets = [];

  @override
  Widget build(BuildContext context) {
    Notifications.setupNotificationActionListener(context);

    m_overdueTestWidgets = getOverdueTestWidgets();

    return Scaffold(body:
    ListView(shrinkWrap: true, children: <Widget>[

      const SizedBox(height: 30),

      const Center(child: SizedBox(height: 50, child:
        Text("Overdue tests", style:
          TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center
        ),
      )),

      SizedBox(width: MediaQuery.of(context).size.width, child:
        ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: m_overdueTestWidgets)
      ),
    ],)
    );
  }

  List<Widget> getOverdueTestWidgets()
  {
    List<Widget> overdueTestWidgets = [];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        for (MemoryNotification memoryNotification in memory.m_notifications)
        {
          if(memoryNotification.m_notifyTime < DateTime.now().millisecondsSinceEpoch && !memoryNotification.m_bHasBeenTested)
          {
            overdueTestWidgets.add(generateOverdueTestWidget(memory, memoryNotification.m_notifyTime));
          }
        }
      }
    }

    return overdueTestWidgets;
  }

  Widget generateOverdueTestWidget(Memory memory, int notifyTime)
  {
    return Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(width: MediaQuery.of(context).size.width * 0.5, child: TextButton(onPressed: () => onTestPressed(memory, notifyTime), child:
        Text(memory.m_question, style: const TextStyle(fontSize: 20.0, color: Colors.blue)))
      ),

      SizedBox(width: MediaQuery.of(context).size.width * 0.4, child: TextButton(onPressed: () => onTestPressed(memory, notifyTime), child:
        Text(Notifications().epochMsToDate(notifyTime), style: const TextStyle(fontSize: 20.0, color: Colors.blue)))
      ),

      SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: TextButton(onPressed: () => onDeleteTestPressed(memory, notifyTime), child:
        const Text("X"))
      )
    ]);
  }

  void onTestPressed(Memory memory, int notifyTime /*todo use notifyTime*/)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory, const PageOverdueTests())));
  }

  void onDeleteTestPressed(Memory memory, int notifyTime)
  {
      for(int i = 0; i < memory.m_notifications.length; i++)
      {
          if(memory.m_notifications[i].m_notifyTime == notifyTime)
          {
            memory.m_notifications[i].m_bHasBeenTested = true;
            break;
          }
      }
      Database().addOrUpdateMemory(memory);

      setState(() {
        m_overdueTestWidgets = getOverdueTestWidgets();
      });
  }
}