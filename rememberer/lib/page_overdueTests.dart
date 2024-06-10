import 'notifications.dart';
import 'package:flutter/material.dart';
import 'memory.dart';
import 'page_test.dart';
import 'page_home.dart';
import 'display.dart';
import 'page_memory.dart';

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

    return WillPopScope(onWillPop: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); return true;}, child: Scaffold(body:
    ListView(shrinkWrap: true, children: <Widget>[

      Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1), child: Text("Overdue tests", style: Display.titleTextStyle, textAlign: TextAlign.center)),

      Visibility(visible: m_overdueTestWidgets.isEmpty, child: Text("No Overdue tests!", style: Display.largeTextStyle, textAlign: TextAlign.center,)),

      ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: m_overdueTestWidgets),
    ],)
    ));
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
            overdueTestWidgets.add(const SizedBox(height: 12));
          }
        }
      }
    }

    return overdueTestWidgets;
  }

  Widget generateOverdueTestWidget(Memory memory, int notifyTime)
  {
    return Row(children: [
      SizedBox(width: MediaQuery.of(context).size.width * 0.05),

      SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: TextButton(onPressed: () => onTestPressed(memory), child:
        Align(alignment: Alignment.centerLeft, child: Text(memory.m_question, style: Display.listItemTextStyle)))
      ),

      SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
        TextButton(onPressed: () => onTestPressed(memory), child: Column(children: [
          Text(Notifications().epochMsToDateTime(notifyTime), style: Display.listItemTextStyle),
          Text(Notifications().epochMsToDateDay(notifyTime), style: Display.listItemTextStyle)
        ],)
      )),

      SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Column(children: [
        TextButton(onPressed: () => onMemoryPressed(memory), child:
          Text("⚙", style: Display.listItemTextStyle)
        ),

        TextButton(onPressed: () => askDeleteTest(memory, notifyTime), child:
          Text("🗑", style: Display.listItemTextStyle)
        )
      ])
      )
    ]);
  }

  void onMemoryPressed(Memory memory) async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
    setState(() {
      m_overdueTestWidgets = getOverdueTestWidgets();
    });
  }

  void onTestPressed(Memory memory)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory, const PageOverdueTests())));
  }

  void onSetTestDone(Memory memory, int notifyTime)
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

      Navigator.of(context).pop();
  }

  void onKeepTest()
  {
    Navigator.of(context).pop();
  }

  void askDeleteTest(Memory memory, int notifyTime)
  {
    showDialog(context: context, builder: (context) => promptDialog("Delete test?", "Are you sure you want to ignore this test?", "Yes", "No", memory, notifyTime));
  }

  AlertDialog promptDialog(String title, String content, String confirmText, String denyText, Memory memory, int notifyTime)
  {
    return AlertDialog(title: Text(title, style: Display.largeTextStyle), content: Text(content, style: Display.normalTextStyle), actions: <Widget>[
      TextButton(onPressed: () => onKeepTest(), child:
        Text(denyText, style: Display.miniNavButtonTextStyle)
      ),

      const SizedBox(width: 10),

      TextButton(onPressed: () => onSetTestDone(memory, notifyTime), child:
        Text(confirmText, style: Display.miniNavButtonTextStyle)
      ),
    ],);
  }
}