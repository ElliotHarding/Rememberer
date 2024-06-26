import 'notifications.dart';
import 'package:flutter/material.dart';
import 'memory.dart';
import 'page_memory.dart';
import 'display.dart';
import 'page_test.dart';

class PageUpcomingNotifications extends StatefulWidget
{
  const PageUpcomingNotifications({Key? key}) : super(key: key);

  @override
  State<PageUpcomingNotifications> createState() => PageUpcomingNotificationsState();
}

class PageUpcomingNotificationsState extends State<PageUpcomingNotifications>
{
  List<Widget> m_notificationsWidget = [];
  bool m_bEnabledOnly = true;
  bool m_bDueOnly = true;

  @override
  Widget build(BuildContext context) {

    Notifications.setupNotificationActionListener(context);

    m_notificationsWidget = getNotificationWidgets();

    return Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1), child: Text("Notifications", style:Display.titleTextStyle, textAlign: TextAlign.center)),

        Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 0, MediaQuery.of(context).size.width * 0.05, MediaQuery.of(context).size.width * 0.05), child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.45, child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text("Enabled only: ", style: Display.searchOptionTextStyle, textAlign: TextAlign.center),
            Checkbox(value: m_bEnabledOnly, onChanged: (bool? value) => onEnabledOnlyCheckboxChanged(value)),
          ])),
          SizedBox(width: MediaQuery.of(context).size.width * 0.45, child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text("Due only: ", style: Display.searchOptionTextStyle, textAlign: TextAlign.center),
            Checkbox(value: m_bDueOnly, onChanged: (bool? value) => onDueOnlyCheckboxChanged(value)),
          ])),
        ])),

        Visibility(visible: m_notificationsWidget.isEmpty, child: Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.1), child: Text("No Notifications!", style: Display.largeTextStyle, textAlign: TextAlign.center,))),

        ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: m_notificationsWidget),
      ],)
    );
  }

  List<Widget> getNotificationWidgets()
  {
    List<MemoryAndNotification> notifications = getUppcommingNotifications();

    List<Widget> widgets = <Widget>[];
    for(MemoryAndNotification memNotification in notifications)
    {
      widgets.add(Row( children: [
        SizedBox(width: MediaQuery.of(context).size.width * 0.05),

        SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: TextButton(onPressed: () => onTestPressed(memNotification.m_memory), child:
          Align(alignment: Alignment.centerLeft, child: Text(memNotification.m_memory.m_question, style: Display.listItemTextStyle)))
        ),

        SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
          TextButton(onPressed: () => onTestPressed(memNotification.m_memory),child: Column(children: [
            Text(Notifications().epochMsToDateTime(memNotification.m_notificationTime), style: Display.listItemTextStyle),
            Text(Notifications().epochMsToDateDay(memNotification.m_notificationTime), style: Display.listItemTextStyle)
          ],)
        )),

        SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Column(children: [
          TextButton(onPressed: () => onQuestionPressed(memNotification.m_memory), child:
            Text("⚙", style: Display.listItemTextStyle)
          ),

          TextButton(onPressed: () => onDeleteNotificationPressed(memNotification), child:
            Text("🗑", style: Display.listItemTextStyle)
          )
          ])
        )
      ]));

      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }

  List<MemoryAndNotification> getUppcommingNotifications()
  {
    List<MemoryAndNotification> notifications = <MemoryAndNotification>[];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        if(!m_bEnabledOnly || memory.m_bNotificationsEnabled)
        {
          for (int notifyTime in memory.getNotifyTimes())
          {
            if(!m_bDueOnly || notifyTime > DateTime.now().millisecondsSinceEpoch)
            {
              notifications.add(MemoryAndNotification(notifyTime, memory));
            }
          }
        }
      }
    }

    notifications.sort((a, b) => a.m_notificationTime.compareTo(b.m_notificationTime));

    return notifications;
  }

  void onEnabledOnlyCheckboxChanged(bool? enabled)
  {
    setState(()
    {
      m_bEnabledOnly = enabled == true;
      m_notificationsWidget = getNotificationWidgets();
    });
  }

  void onDueOnlyCheckboxChanged(bool? enabled)
  {
    setState(()
    {
      m_bDueOnly = enabled == true;
      m_notificationsWidget = getNotificationWidgets();
    });
  }

  void deleteNotification(MemoryAndNotification memoryNotification) async
  {
    await Notifications().removeNotification(memoryNotification.m_memory.key.toString() + "-" + memoryNotification.m_notificationTime.toString());

    memoryNotification.m_memory.removeNotification(memoryNotification.m_notificationTime);
    Database().addOrUpdateMemory(memoryNotification.m_memory);
  }

  void onTestPressed(Memory memory)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory, const PageUpcomingNotifications())));
  }

  void onQuestionPressed(Memory memory) async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
    setState(() {
      m_notificationsWidget = getNotificationWidgets();
    });
  }

  void onDeleteNotificationPressed(MemoryAndNotification memNotification)
  {
    deleteNotification(memNotification);
    setState(() {
      m_notificationsWidget = getNotificationWidgets();
    });
  }
}

class MemoryAndNotification
{
  MemoryAndNotification(int notificationTime, Memory memory)
  {
    m_notificationTime = notificationTime;
    m_memory = memory;
  }

  int m_notificationTime = 0;
  Memory m_memory = Memory();
}