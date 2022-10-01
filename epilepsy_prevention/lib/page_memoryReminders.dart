import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'dart:math';
import 'package:epilepsy_prevention/notifications.dart';
import 'package:fl_chart/fl_chart.dart';

class PageMemoryReminders extends StatefulWidget
{
  PageMemoryReminders({required this.m_memory, Key? key}) : super(key: key);

  Memory m_memoryBefore = Memory();
  Memory m_memory;

  //Notification gen vars
  int m_currentIteration = 1;
  int m_maxNotifications = 1;

  //Graph stuff
  int m_graphMaxTime = 0;
  int m_graphMinTime = 0;
  int m_graphViewIterationsCount = 1;
  List<ScatterSpot> m_graphDataPoints = [];

  @override
  State<PageMemoryReminders> createState() => PageMemoryRemindersState();
}

class PageMemoryRemindersState extends State<PageMemoryReminders>
{

  void initState()
  {
    setState(()
    {
      widget.m_memoryBefore = widget.m_memory;

      if(widget.m_memory.m_notifyTimes.isEmpty)
      {
        widget.m_maxNotifications = 1;
      }
      else
      {
        widget.m_maxNotifications = widget.m_memory.m_notifyTimes.length;
      }

      widget.m_currentIteration = getCurrentIteration(widget.m_memory);
      updateNotifyTimes();
    });
  }

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

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
          Slider(value: widget.m_maxNotifications.toDouble(), min: 1, max: 25, onChanged: (newValue) => onMaxNotificationSliderChanged(newValue.toInt())
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Text("Current Notification: " + widget.m_currentIteration.toInt().toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          Slider(value: widget.m_currentIteration.toDouble(), min: 1, max: widget.m_maxNotifications.toDouble(), onChanged: (newValue) => onCurrentIterationSliderChanged(newValue.toInt())
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.7 + 125, child:
            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 50, child:
                const Text("Graph Timescale:", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)
              )),

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child:
                Slider(value: widget.m_graphViewIterationsCount.toDouble(), min: 1, max: widget.m_memory.m_notifyTimes.isEmpty ? 1 : widget.m_memory.m_notifyTimes.length.toDouble(), onChanged: (newValue) => onGraphViewIterationsSliderChanged(newValue.toInt())
              ))),

              const SizedBox(height: 10),

              SizedBox(width: MediaQuery.of(context).size.width * 0.95, height: MediaQuery.of(context).size.height * 0.7, child:
                ScatterChart(
                  ScatterChartData(
                    scatterSpots: widget.m_graphDataPoints,
                    minX: 1,
                    maxX: widget.m_graphViewIterationsCount.toDouble(),
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
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: getIterationIndexValues, interval: 1)),
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

    return SideTitleWidget(axisSide: meta.axisSide, child:
      Text(timeStr, style: const TextStyle(color: Colors.blue, fontSize: 13))
    );
  }

  Widget getIterationIndexValues(double value, TitleMeta meta)
  {
    return SideTitleWidget(axisSide: meta.axisSide, child:
      Text(value.toInt().toString(), style: const TextStyle(color: Colors.blue, fontSize: 13))
    );
  }

  //Must be called in setState!
  void updateGraphValues(List<int> notifyTimes)
  {
    if(notifyTimes.isEmpty)
    {
      widget.m_graphMaxTime = 0;
      widget.m_graphMinTime = 0;
      widget.m_graphDataPoints = [];
      return;
    }

    notifyTimes.sort((a, b) => a.compareTo(b));

    var nowMs = DateTime.now().millisecondsSinceEpoch;
    widget.m_graphMinTime = notifyTimes[0] - nowMs;
    widget.m_graphMaxTime = notifyTimes[widget.m_graphViewIterationsCount-1] - nowMs;

    List<ScatterSpot> graphData = [];
    for(int i = 1; i <= widget.m_graphViewIterationsCount; i++)
    {
        graphData.add(ScatterSpot(i.toDouble(), (notifyTimes[i-1] - nowMs).toDouble(), color: Colors.blue, radius: 5));
    }

    widget.m_graphDataPoints = graphData;
  }

  //Must be called inside setState!
  void updateNotifyTimes()
  {
    if (widget.m_memory.m_testFrequecy == "Rare")
    {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration, widget.m_maxNotifications, 4, 1800000);
    }
    else if (widget.m_memory.m_testFrequecy == "Occasionally")
    {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration, widget.m_maxNotifications, 3, 1200000);
    }
    else if (widget.m_memory.m_testFrequecy == "Frequently")
    {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_currentIteration, widget.m_maxNotifications, 2, 900000);
    }
    else
    {
      widget.m_memory.m_notifyTimes = [];
      widget.m_graphViewIterationsCount = 1;

      updateGraphValues(widget.m_memory.m_notifyTimes);
      return;
    }

    widget.m_graphViewIterationsCount = widget.m_memory.m_notifyTimes.length;
    updateGraphValues(widget.m_memory.m_notifyTimes);
  }

  void onCurrentIterationSliderChanged(int newValue)
  {
    setState(()
    {
      widget.m_currentIteration = newValue;
      updateNotifyTimes();
    });
  }

  void onGraphViewIterationsSliderChanged(int newValue)
  {
    setState(()
    {
      widget.m_graphViewIterationsCount = newValue;
      updateGraphValues(widget.m_memory.m_notifyTimes);
    });
  }

  void onMaxNotificationSliderChanged(int newValue)
  {
    setState(()
    {
      if(widget.m_currentIteration > newValue)
      {
        widget.m_currentIteration = newValue;
      }

      widget.m_maxNotifications = newValue;

      updateNotifyTimes();
    });
  }

  void onFrequencyDropDownChanged(String? selectedValue)
  {
    setState(() {
      if (selectedValue != null) {
        widget.m_memory.m_testFrequecy = selectedValue;
      }

      updateNotifyTimes();
    });
  }

  void onCancel(BuildContext context)
  {
    Navigator.pop(context, widget.m_memoryBefore);
  }

  void onUpdate(BuildContext context)
  {
    Navigator.pop(context, widget.m_memory);
  }

  List<int> genNotifyTimes(int iStart, int iMaxNotifications, double incFactor, int incTime)
  {
    List<int> values = [];
    values.add(DateTime.now().millisecondsSinceEpoch + 30000);
    for(int i = iStart; i < iMaxNotifications; i++)
    {
      values.add(DateTime.now().millisecondsSinceEpoch + incTime * pow(incFactor, i).toInt());
    }
    return values;
  }

  int getCurrentIteration(Memory memory)
  {
    if(memory.m_notifyTimes.isEmpty)
    {
        return 1;
    }

    List<int> notifyTimesSorted = memory.m_notifyTimes;
    notifyTimesSorted.sort((a, b) => a.compareTo(b));

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    for(int i = 0; i < notifyTimesSorted.length; i++)
    {
      if(currentTime < notifyTimesSorted[i])
      {
        return i + 1;
      }
    }

    return notifyTimesSorted.length;
  }
}