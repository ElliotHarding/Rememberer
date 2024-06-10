import 'notifications.dart';
import 'package:flutter/material.dart';
import 'memory.dart';
import 'display.dart';

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
          Text("Enable Notifications: ", style: Display.largeTextStyle, textAlign: TextAlign.center),
          Checkbox(value: m_bNotificationsEnabled, onChanged: (bool? value) => setEnableNotifications(value))
        ]),

        const Spacer(),

        TextButton(onPressed: () => askDeleteAllMemories(), child:
          Text("Delete all memories", style: Display.largeTextStyle)
        ),

        const Spacer(),

        TextButton(onPressed: () => askDeleteAllNotifications(), child:
          Text("Delete all notifications", style: Display.largeTextStyle)
        ),

        const Spacer(),

        TextButton(onPressed: () => askGenTestData(), child:
          Text("Generate test data", style: Display.largeTextStyle)
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
            Notifications().scheduleNotifications(memory.key, memory.m_question, memory.getNotifyTimes());
          }
        }
      }
      else
      {
        Database().setNotificationsEnabledSetting(false);

        for(Memory memory in box.values)
        {
          Notifications().removeNotifications(memory.key, memory.getNotifyTimes());
        }
      }
    }
  }

  void askGenTestData()
  {
    showDialog(context: context, builder: (context) => promptDialog("Generate test data?", "Are you sure you want to generate test data?", "Generate", "Cancel", onGenerateTestData, onAbortPromptDialog));
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
    return AlertDialog(title: Text(title, style: Display.largeTextStyle), content: Text(content, style: Display.normalTextStyle), actions: <Widget>[
      TextButton(onPressed: () => denyAction(), child:
        Text(denyText, style: Display.miniNavButtonTextStyle)
      ),

      const SizedBox(width: 10),

      TextButton(onPressed: () => confirmAction(), child:
        Text(confirmText, style: Display.miniNavButtonTextStyle)
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

  void onGenerateTestData()
  {
    Database().generateTestData();
    Navigator.of(context).pop();
  }
}