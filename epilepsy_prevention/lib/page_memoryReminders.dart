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

  int m_graphMaxTime = 0;
  int m_graphMinTime = 0;
  int m_graphViewIterationsCount = 0;
  List<ScatterSpot> m_graphDataPoints = [];

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
    widget.m_graphViewIterationsCount = widget.m_maxNotifications.toInt();

    updateGraphValues(widget.m_memory.m_notifyTimes);
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

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Text("Current Notification: " + widget.m_currentIteration.toInt().toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          Slider(value: widget.m_currentIteration, min: 0, max: widget.m_maxNotifications, onChanged: (newValue) => onCurrentIterationSliderChanged(newValue)
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.7 + 125, child:
            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 50, child:
                const Text("Graph Timescale:", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)
              )),

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
                Slider(value: widget.m_graphViewIterationsCount.toDouble(), min: 0, max: widget.m_maxNotifications, onChanged: (newValue) => onGraphViewIterationsCountChanged(newValue)
              ))),

              const SizedBox(height: 10),

              SizedBox(width: MediaQuery.of(context).size.width * 0.95, height: MediaQuery.of(context).size.height * 0.7, child:
                ScatterChart(
                  ScatterChartData(
                    scatterSpots: widget.m_graphDataPoints,
                    minX: 0,
                    maxX: 30,
                    minY: widget.m_graphMinTime.toDouble(),
                    maxY: widget.m_graphMaxTime.toDouble(),
                    borderData: FlBorderData(
                      show: true,
                    ),
                    gridData: FlGridData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: getIterationIndexValues)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 70, getTitlesWidget: getDateIndexValues)),
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
              ),

              const SizedBox(height: 10),

              SizedBox(width: MediaQuery.of(context).size.width, height: 20, child:
                const Text("Test number", style: TextStyle(fontSize: 20, color: Colors.blue), textAlign: TextAlign.center)
              ),
            ],),
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

  Widget getDateIndexValues(double value, TitleMeta meta)
  {
    String timeStr;

    var minutes = value.toInt() / 60000;
    if(minutes < 120 && minutes > -120)
    {
      timeStr = minutes.toInt().toString() + " min";
    }
    else
    {
      var hours = value.toInt() / 3600000;
      if(hours < 48 && hours > -48)
      {
        timeStr = hours.toInt().toString() + " Hrs";
      }
      else
      {
        var days = hours / 24;
        timeStr = days.toInt().toString() + " Days";
      }
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(timeStr, style: const TextStyle(color: Colors.blue, fontSize: 13)),
    );
  }

  Widget getIterationIndexValues(double value, TitleMeta meta)
  {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(value.toInt().toString(), style: const TextStyle(color: Colors.blue, fontSize: 13)),
    );
  }

  void updateGraphValues(List<int> notifyTimes)
  {
    if(notifyTimes.isEmpty)
    {
      setState(()
      {
        widget.m_graphMaxTime = 0;
        widget.m_graphMinTime = 0;
        widget.m_graphDataPoints = [];
      });
      return;
    }

    notifyTimes.sort((a, b) => a.compareTo(b));

    var nowMs = DateTime.now().millisecondsSinceEpoch;
    widget.m_graphMinTime = notifyTimes[0] - nowMs;
    widget.m_graphMaxTime = notifyTimes[widget.m_graphViewIterationsCount] - nowMs;

    List<ScatterSpot> graphData = [];
    for(int i = 1; i <= widget.m_graphViewIterationsCount; i++)
    {
        graphData.add(ScatterSpot(i.toDouble(), (notifyTimes[i-1] - nowMs).toDouble(), color: Colors.blue, radius: 5));
    }

    setState(()
    {
      widget.m_graphDataPoints = graphData;
    });
  }

  void updateNotifyTimes()
  {
    setState(()
    {
      if (widget.m_memory.m_testFrequecy == "Rare") {
        widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 4, 1800000);
      }
      else if (widget.m_memory.m_testFrequecy == "Occasionally") {
        widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 3, 1200000);
      }
      else if (widget.m_memory.m_testFrequecy == "Frequently") {
        widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration.toInt(), widget.m_maxNotifications.toInt(), 2, 900000);
      }
      else
      {
        widget.m_memory.m_notifyTimes = [];
      }
    });

    updateGraphValues(widget.m_memory.m_notifyTimes);
  }

  void onCurrentIterationSliderChanged(double newValue)
  {
    setState(()
    {
      widget.m_currentIteration = newValue;
    });
  }

  void onGraphViewIterationsCountChanged(double newValue)
  {
    setState(()
    {
      widget.m_graphViewIterationsCount = newValue.toInt();
    });

    updateGraphValues(widget.m_memory.m_notifyTimes);
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

      if(widget.m_graphViewIterationsCount > newValue)
      {
        widget.m_graphViewIterationsCount = newValue.toInt();
      }

      widget.m_maxNotifications = newValue;
    });

    updateNotifyTimes();
  }

  void onFrequencyDropDownChanged(String? selectedValue)
  {
    setState(() {
      if (selectedValue != null) {
        widget.m_memory.m_testFrequecy = selectedValue;
      }
    });

    updateNotifyTimes();
  }

  void onCancel(BuildContext context)
  {
    Navigator.pop(context, m_memoryBefore);
  }

  void onUpdate(BuildContext context)
  {
    Navigator.pop(context, widget.m_memory);
  }

  List<int> genNotifyTimes(int iStart, int iMaxNotifications, double incFactor, int incTime)
  {
    List<int> values = [];
    values.add(DateTime.now().millisecondsSinceEpoch + 30000);
    for(int i = iStart; i < iMaxNotifications-1 /*TEST CODE '-1'*/; i++)
    {
      values.add(DateTime.now().millisecondsSinceEpoch + incTime * pow(incFactor, i).toInt());
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