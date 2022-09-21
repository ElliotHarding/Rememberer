import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';

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

          const Text( "Enable: ", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),

          const Spacer()
        ],)
    );
  }
}