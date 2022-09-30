import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'dart:math';
import 'package:epilepsy_prevention/notifications.dart';
import 'package:fl_chart/fl_chart.dart';

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
    Notifications.setupNotificationActionListener(context);

    m_memoryBefore = widget.m_memory;

    return WillPopScope(onWillPop: () async {Navigator.pop(context, m_memoryBefore); return true;}, child:
      Scaffold(body:
        Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: const Text("Reminder frequency", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            DropdownButton(value: widget.m_memory.m_testFrequecy, onChanged: (String? selectedValue) => onFrequencyDropDownChanged(selectedValue), items: const [
                DropdownMenuItem(value: "Never", child: Text("Never", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                DropdownMenuItem(value: "Rare", child: Text("Rare", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                DropdownMenuItem(value: "Occasionally", child: Text("Occasionally", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                DropdownMenuItem(value: "Frequently", child: Text("Frequently", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center))
              ],
          )),

          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: Text("Max Notifications: " + widget.m_maxNotifications.toInt().toString(), style: const TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
            Slider(value: widget.m_maxNotifications, min: 0, max: 25, onChanged: (newValue) => onMaxNotificationSliderChanged(newValue)
          )),

          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: Text("Current Notification: " + widget.m_currentIteration.toInt().toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
            Slider(value: widget.m_currentIteration, min: 0, max: widget.m_maxNotifications, onChanged: (newValue) => onCurrentIterationSliderChanged(newValue)
          )),

          const Spacer(),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          GestureDetector(
            onTap: () {
              setState(() {

              });
            },
            child: AspectRatio(
              aspectRatio: 1,
              child: Card(
                color: const Color(0xffffffff),
                elevation: 6,
                child: ScatterChart(
                  ScatterChartData(
                    scatterSpots: [ScatterSpot(20, 14.5, color: Colors.blue, radius: 5)],
                    minX: 0,
                    maxX: 30,
                    minY: 0,
                    maxY: 30,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    gridData: FlGridData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                      show: false,
                    ),
                    scatterTouchData: ScatterTouchData(
                      enabled: false,
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 600),
                  swapAnimationCurve: Curves.fastOutSlowIn,
                ),
              ),
            ),
          )
          ),

          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            TextButton(onPressed: () => onCancel(context), child: const Text("Cancel", style: TextStyle(fontSize: 30, color: Colors.blue))),

            TextButton(onPressed: () => onUpdate(context), child: const Text("Update", style: TextStyle(fontSize: 30, color: Colors.blue)))
          ]),

          const Spacer()
        ])
    ));
  }

  void onCurrentIterationSliderChanged(double newValue)
  {
    setState(() {
      widget.m_currentIteration = newValue;
    });
  }

  void onMaxNotificationSliderChanged(double newValue)
  {
    setState(()
    {
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
  }

  void onFrequencyDropDownChanged(String? selectedValue)
  {
    setState(() {
      if (selectedValue != null) {
        widget.m_memory.m_testFrequecy = selectedValue;
      }
    });
  }

  void onCancel(BuildContext context)
  {
    Navigator.pop(context, m_memoryBefore);
  }

  void onUpdate(BuildContext context)
  {
    //Gen new notify times
    if (widget.m_memory.m_testFrequecy == "Rare") {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt() + 1, widget.m_maxNotifications.toInt(), 4, 1800000);
    }
    else if (widget.m_memory.m_testFrequecy == "Occasionally") {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 3, 1200000);
    }
    else if (widget.m_memory.m_testFrequecy == "Frequently") {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 2, 900000);
    }

    Navigator.pop(context, widget.m_memory);
  }

  List<int> genNotifyTimes(int iStart, int iMaxNotifications, double incFactor, int incTime)
  {
    List<int> values = [];
    for(int i = iStart; i < iMaxNotifications; i++)
    {
      values.add(DateTime.now().millisecondsSinceEpoch + incTime * pow(incFactor, i).toInt());
    }
    values.add(DateTime.now().millisecondsSinceEpoch + 30000);
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