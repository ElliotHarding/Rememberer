import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/notifications.dart';
import 'dart:math';

class PageMemoryReminders extends StatefulWidget
{
  PageMemoryReminders({required this.m_memory, Key? key}) : super(key: key);

  Memory m_memory;
  double m_currentIteration = 0;
  double m_maxNotifications = 0;

  @override
  State<PageMemoryReminders> createState() => PageMemoryRemindersState();
}

class PageMemoryRemindersState extends State<PageMemoryReminders>
{
  Memory m_memoryBefore = Memory();

  void initState()
  {
    widget.m_maxNotifications = widget.m_memory.m_notifyTimes.length.toDouble();
    widget.m_currentIteration = getCurrentIteration().toDouble();
  }

  Widget build(BuildContext context)
  {
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

    m_memoryBefore = widget.m_memory;

    return WillPopScope(onWillPop: () async {Navigator.pop(context, m_memoryBefore); return true;}, child:
      Scaffold(body:
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: const Text("Reminder frequency", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            DropdownButton(items: const [
                DropdownMenuItem(value: "Never", child: Text("Never", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                DropdownMenuItem(value: "Rare", child: Text("Rare", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                DropdownMenuItem(value: "Occasionally", child: Text("Occasionally", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                DropdownMenuItem(value: "Frequently", child: Text("Frequently", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center))
              ],
              value: widget.m_memory.m_testFrequecy,
              onChanged: (String? selectedValue) {
                setState(() {
                  if (selectedValue != null) {
                    widget.m_memory.m_testFrequecy = selectedValue;
                  }
                });
              }
          )),

          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: Text("Max Notifications: " + widget.m_maxNotifications.toInt().toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
            Slider(
              value: widget.m_maxNotifications,
              min: 0,
              max: 25,
              onChanged: (newValue) {
                setState(() {
                  newValue = newValue.toInt().toDouble();

                  if(newValue > 30)
                  {
                    newValue = 30;
                  }

                  if(widget.m_currentIteration > newValue)
                  {
                    widget.m_currentIteration = newValue;
                  }

                  widget.m_maxNotifications = newValue;
                });
              },
          )),

          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: Text("Current Notification: " + widget.m_currentIteration.toInt().toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
            Slider(
              value: widget.m_currentIteration,
              min: 0,
              max: widget.m_maxNotifications,
              onChanged: (newValue) {
                setState(() {
                  widget.m_currentIteration = newValue;
                });
              },
          )),

          const Spacer(),

          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            TextButton(onPressed: () => onCancel(context), child: const Text("Cancel", style: TextStyle(fontSize: 30, color: Colors.blue))),

            TextButton(onPressed: () => onUpdate(context), child: const Text("Update", style: TextStyle(fontSize: 30, color: Colors.blue)))
          ]),

          const Spacer()
        ])
    ));
  }

  void onCancel(BuildContext context)
  {
    Navigator.pop(context, m_memoryBefore);
  }

  void onUpdate(BuildContext context)
  {
    //Gen new notify times
    if (widget.m_memory.m_testFrequecy == "Rare") {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 4, 0.7);
    }
    else if (widget.m_memory.m_testFrequecy == "Occasionally") {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 4, 0.7);
    }
    else if (widget.m_memory.m_testFrequecy == "Frequently") {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 4, 0.7);
    }

    Navigator.pop(context, widget.m_memory);
  }

  List<int> genNotifyTimes(int iStart, int iMaxNotifications, double b, double k)
  {
    List<int> values = [];
    for(int i = iStart; i < iMaxNotifications; i++)
    {
      values.add(DateTime.now().millisecondsSinceEpoch + pow(b, k * i).toInt());
    }
    return values;
  }

  int getCurrentIteration()
  {
    if(widget.m_memory.m_notifyTimes.isEmpty)
    {
        return 0;
    }

    List<int> notifyTimesSorted = widget.m_memory.m_notifyTimes;
    notifyTimesSorted.sort((a, b) => a.compareTo(b));

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    for(int i = 0; i < notifyTimesSorted.length; i++)
    {
      if(currentTime < notifyTimesSorted[i])
      {
        return i;
      }
    }

    return notifyTimesSorted.length;
  }
}