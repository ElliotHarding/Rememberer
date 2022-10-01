import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';

class PageSettings extends StatefulWidget
{
  const PageSettings({Key? key}) : super(key: key);

  @override
  State<PageSettings> createState() => PageSettingsState();
}

class PageSettingsState extends State<PageSettings>
{
  bool? m_bNotificationsEnabled = Database().getNotificationsEnabledSetting();

  @override
  Widget build(BuildContext context) {

    Notifications.setupNotificationActionListener(context);

    return Scaffold(body:
      Column(children: [
        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Text("Enable Notifications: ", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center),
          Checkbox(value: m_bNotificationsEnabled, onChanged: (bool? value) => setEnableNotifications(value))
        ]),

        const Spacer(),

        TextButton(onPressed: () => askDeleteAllMemories(), child:
          const Text("Delete all memories", style: TextStyle(fontSize: 30.0, color: Colors.blue))
        ),

        const Spacer(),

        TextButton(onPressed: () => askDeleteAllNotifications(), child:
          const Text("Delete all notifications", style: TextStyle(fontSize: 30.0, color: Colors.blue))
        ),

        const Spacer()
      ],)
    );
  }

  void setEnableNotifications(bool? enable)
  {
    setState(()
    {
      m_bNotificationsEnabled = enable == true;
    });

    var box = Database().getMemoryBox();
    if(box != null)
    {
      if(m_bNotificationsEnabled == true)
      {
        Database().setNotificationsEnabledSetting(true);

        for(Memory memory in box.values)
        {
          if(memory.m_bNotificationsEnabled)
          {
            Notifications().scheduleNotifications(memory.key, memory.m_question, memory.m_notifyTimes);
          }
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

  void askDeleteAllNotifications()
  {
    showDialog(context: context, builder: (context) => promptDialog("Delete all notifications?", "Are you sure you want to delete all notifications?", "Delete", "Cancel", onDeleteAllNotifications, onAbortPromptDialog));
  }

  void askDeleteAllMemories()
  {
    showDialog(context: context, builder: (context) => promptDialog("Delete all memories?", "Are you sure you want to delete all memories?", "Delete", "Cancel", onDeleteAllMemories, onAbortPromptDialog));
  }

  AlertDialog promptDialog(String title, String content, String confirmText, String denyText, var confirmAction, var denyAction)
  {
    return AlertDialog(title: Text(title), content: Text(content), actions: <Widget>[
      TextButton(onPressed: () => denyAction(), child:
        Text(denyText, style: const TextStyle(fontSize: 30.0, color: Colors.blue))
      ),

      TextButton(onPressed: () => confirmAction(), child:
        Text(confirmText, style: const TextStyle(fontSize: 30.0, color: Colors.blue))
      ),
    ],);
  }

  void onDeleteAllMemories()
  {
    Database().deleteAllMemories();

    Navigator.of(context).pop();
  }

  void onAbortPromptDialog()
  {
    Navigator.of(context).pop();
  }

  void onDeleteAllNotifications()
  {
    Database().deleteAllNotifyTimes();

    Navigator.of(context).pop();
  }
}