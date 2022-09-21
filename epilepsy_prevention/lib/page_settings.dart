import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';

class PageSettings extends StatefulWidget
{
  const PageSettings({Key? key}) : super(key: key);

  @override
  State<PageSettings> createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings>
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
            Notifications.m_selectedNotificationSubject.add(null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(mem)));
          }
        }
      }
    });

    return Scaffold(
        body: Column(children: [

          const Spacer(),

          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            const Text( "Enable: ", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
            Checkbox(value: m_bAppEnabled, onChanged: (bool? value){setState((){
              m_bAppEnabled = value;

              setEnableNotifications();
            });})
          ]
          ),

          const Spacer()
        ],)
    );
  }

  void setEnableNotifications()
  {
    var box = Database().getMemoryBox();
    if(box != null)
    {
      if(m_bAppEnabled == true)
      {
        Database().setNotificationsEnabledSetting(true);

        for(Memory memory in box.values)
        {
          Notifications().scheduleNotifications(memory.key, memory.m_question, memory.m_notifyTimes);
        }
      }
      else
      {
        Database().setNotificationsEnabledSetting(false);

        for(Memory memory in box.values)
        {
          Notifications().removeNotifications(memory.key, memory.m_notifyTimes);
        }
      }
    }
  }
}