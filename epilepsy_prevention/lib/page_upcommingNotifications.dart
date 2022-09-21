import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:epilepsy_prevention/page_memory.dart';

class PageUpcommingNotifications extends StatefulWidget
{
  const PageUpcommingNotifications({Key? key}) : super(key: key);

  @override
  State<PageUpcommingNotifications> createState() => PageUpcommingNotificationsState();
}

class PageUpcommingNotificationsState extends State<PageUpcommingNotifications>
{
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
            Notifications.m_selectedNotificationSubject.add(null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(mem)));
          }
        }
      }
    });

    return Scaffold(
        body: Column(children: [

          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: ListView(
              children: getNotificationWidgets(context))
          ),

          const Spacer()
        ],)
    );
  }

  List<Widget> getNotificationWidgets(BuildContext context)
  {


    List<MemoryNotification> notifications = <MemoryNotification>[];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        for (int notifyTime in memory.m_notifyTimes)
        {
          notifications.add(MemoryNotification(notifyTime, memory));
        }
      }
    }

    notifications.sort((a, b) => a.m_notificationTime.compareTo(b.m_notificationTime));

    List<Widget> widgets = <Widget>[];
    for(MemoryNotification memNotification in notifications)
    {
      widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          SizedBox(width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.height * 0.1, child: TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memNotification.m_memory)));
          }, child: Text(memNotification.m_memory.m_question, style: const TextStyle(fontSize: 20.0, color: Colors.blue)))),

          SizedBox(width: MediaQuery.of(context).size.width * 0.4, height: MediaQuery.of(context).size.height * 0.1, child: TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memNotification.m_memory)));
          }, child: Text(memNotification.m_notificationTime.toString(), style: const TextStyle(fontSize: 20.0, color: Colors.blue)))),

          SizedBox(width: MediaQuery.of(context).size.width * 0.2, height: MediaQuery.of(context).size.height * 0.1, child: TextButton(onPressed: () {

          }, child: const Text("X")))
        ],
      ));
    }

    return widgets;
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