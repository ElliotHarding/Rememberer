import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memory.dart';

class PageUpcomingNotifications extends StatefulWidget
{
  const PageUpcomingNotifications({Key? key}) : super(key: key);

  @override
  State<PageUpcomingNotifications> createState() => PageUpcomingNotificationsState();
}

class PageUpcomingNotificationsState extends State<PageUpcomingNotifications>
{
  List<Widget> m_notificationsWidget = [];

  @override
  Widget build(BuildContext context) {

    Notifications.setupNotificationActionListener(context);

    m_notificationsWidget = getNotificationWidgets(context);

    return Scaffold(
        body: Column(children: [

          SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.2, child:
            const Center(child:
              Text("Notifications", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.left),
            )
          ),

          SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.8, child:
            ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: m_notificationsWidget)
          ),
        ],)
    );
  }

  List<Widget> getNotificationWidgets(BuildContext context)
  {
    List<MemoryNotification> notifications = getUppcommingNotifications();

    List<Widget> widgets = <Widget>[];
    for(MemoryNotification memNotification in notifications)
    {
      widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.height * 0.1, child: TextButton(onPressed: () => onQuestionPressed(memNotification.m_memory, context), child:
          Text(memNotification.m_memory.m_question, style: const TextStyle(fontSize: 20.0, color: Colors.blue)))
        ),

        SizedBox(width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.height * 0.1, child: TextButton(onPressed: () => onQuestionPressed(memNotification.m_memory, context), child:
          Text(epochMsToDate(memNotification.m_notificationTime), style: const TextStyle(fontSize: 20.0, color: Colors.blue)))
        ),

        SizedBox(width: MediaQuery.of(context).size.width * 0.2, height: MediaQuery.of(context).size.height * 0.1, child: TextButton(onPressed: () => onDeleteNotificationPressed(memNotification, context), child:
          const Text("X"))
        )
      ]));
    }

    return widgets;
  }

  List<MemoryNotification> getUppcommingNotifications()
  {
    List<MemoryNotification> notifications = <MemoryNotification>[];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        for (int notifyTime in memory.m_notifyTimes)
        {
          if(notifyTime > DateTime.now().millisecondsSinceEpoch)
          {
            notifications.add(MemoryNotification(notifyTime, memory));
          }
        }
      }
    }

    notifications.sort((a, b) => a.m_notificationTime.compareTo(b.m_notificationTime));

    return notifications;
  }

  void deleteNotification(MemoryNotification memoryNotification) async
  {
    await Notifications().removeNotification(memoryNotification.m_memory.key.toString() + "-" + memoryNotification.m_notificationTime.toString());

    memoryNotification.m_memory.m_notifyTimes.remove(memoryNotification.m_notificationTime);
    Database().addOrUpdateMemory(memoryNotification.m_memory);
  }

  String epochMsToDate(int epochMs)
  {
    var date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return date.toString();
  }

  void onQuestionPressed(Memory memory, BuildContext context) async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
    setState(() {
      m_notificationsWidget = getNotificationWidgets(context);
    });
  }

  void onDeleteNotificationPressed(MemoryNotification memNotification, BuildContext context)
  {
    deleteNotification(memNotification);
    setState(() {
      m_notificationsWidget = getNotificationWidgets(context);
    });
  }
}

class MemoryNotification
{
  MemoryNotification(int notificationTime, Memory memory)
  {
    m_notificationTime = notificationTime;
    m_memory = memory;
  }

  int m_notificationTime = 0;
  Memory m_memory = Memory();
}