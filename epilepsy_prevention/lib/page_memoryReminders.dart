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

    return WillPopScope(onWillPop: () async {onUpdate(context); return true;}, child:
      Scaffold(body: ListView(shrinkWrap: true, children: <Widget>[

        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: const Text("Reminder frequency", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          DropdownButton(value: widget.m_memory.m_testFrequecy, onChanged: (String? selectedValue) => onFrequencyDropDownChanged(selectedValue), items: const [
              DropdownMenuItem(value: "Never", child: Text("Never", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Rare", child: Text("Rare", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Occasionally", child: Text("Occasionally", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Frequently", child: Text("Frequently", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center))
            ],
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Text("Max Notifications: " + widget.m_maxNotifications.toInt().toString(), style: const TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          Slider(value: widget.m_maxNotifications, min: 0, max: 25, onChanged: (newValue) => onMaxNotificationSliderChanged(newValue)
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: Text("Current Notification: " + widget.m_currentIteration.toInt().toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
          Slider(value: widget.m_currentIteration, min: 0, max: widget.m_maxNotifications, onChanged: (newValue) => onCurrentIterationSliderChanged(newValue)
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: MediaQuery.of(context).size.height * 0.7, child:
            Row(children: [

              SizedBox(width: MediaQuery.of(context).size.width * 0.1, height: MediaQuery.of(context).size.height * 0.7, child:
                  const RotatedBox(quarterTurns: 1, child: Center(child:
                    Text("Value", style: TextStyle(fontSize: 15, color: Colors.blue), textAlign: TextAlign.center,),
                  ))
              ),

              SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.7, child:
                ScatterChart(
                  ScatterChartData(
                    scatterSpots: [ScatterSpot(20, 14.5, color: Colors.blue, radius: 5)],
                    minX: 0,
                    maxX: 30,
                    minY: 0,
                    maxY: 30,
                    borderData: FlBorderData(
                      show: true,
                    ),
                    gridData: FlGridData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))
                    ),
                    scatterTouchData: ScatterTouchData(
                      enabled: true,
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 600),
                  swapAnimationCurve: Curves.fastOutSlowIn,
                ),
              )
            ],)
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: () => onCancel(context), child: const Text("Cancel", style: TextStyle(fontSize: 30, color: Colors.blue))),

          TextButton(onPressed: () => onUpdate(context), child: const Text("Update", style: TextStyle(fontSize: 30, color: Colors.blue)))
        ]),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
       ])
    ));
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.blue,
      fontSize: 15
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('M', style: style);
        break;
      case 1:
        text = const Text('T', style: style);
        break;
      case 2:
        text = const Text('W', style: style);
        break;
      case 3:
        text = const Text('T', style: style);
        break;
      case 4:
        text = const Text('F', style: style);
        break;
      case 5:
        text = const Text('S', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
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