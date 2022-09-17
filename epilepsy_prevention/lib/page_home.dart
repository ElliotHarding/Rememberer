import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memories.dart';
import 'package:epilepsy_prevention/page_test.dart';

class PageHome extends StatefulWidget
{
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome>
{
  bool? m_bAppEnabled = Database().getNotificationsEnabledSetting();

  @override
  Widget build(BuildContext context) {

    Notifications.m_selectedNotificationSubject.stream.listen((String? memoryKey) async {
      if(memoryKey != null) {
        var database = Database();
        int? keyValue = int.tryParse(memoryKey);
        if(keyValue != null)
        {
          Memory? mem = database.getMemoryWithId(keyValue);
          if (mem != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(mem)));
          }
        }
      }
    });

    return Scaffold(
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Text( "Enable: ", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
          Checkbox(value: m_bAppEnabled, onChanged: (bool? value){setState((){
            m_bAppEnabled = value;

            var box = Database().getMemoryBox();
            if(box != null)
            {
              if(m_bAppEnabled == true)
              {
                Database().setNotificationsEnabledSetting(true);

                for(Memory memory in box.values)
                {
                  for (int notifyTime in memory.m_notifyTimes)
                  {
                    Notifications().scheduleNotification(memory.key, memory, notifyTime, memory.key.toString() + "-" + notifyTime.toString());
                  }
                }
              }
              else
              {
                Database().setNotificationsEnabledSetting(false);

                for(Memory memory in box.values)
                {
                  for (int notifyTime in memory.m_notifyTimes)
                  {
                    Notifications().removeNotification(memory.key.toString() + "-" + notifyTime.toString());
                  }
                }
              }
            }
          });})
          ]
        ),

        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
          }, child: const Text("Add new entry"))
        ]
        ),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
          }, child: const Text("View Memories"))
        ]
        ),
      ],)
    );
  }
}