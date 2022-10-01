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
  int m_notificationStartGoal = 0;
  int m_notificationCountGoal = 0;

  //Graph stuff
  int m_graphMaxTime = 0;
  int m_graphMinTime = 0;
  int m_graphViewIterationsCount = 0;
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

      widget.m_notificationCountGoal = widget.m_memory.m_notifyTimes.length;

      widget.m_notificationStartGoal = getCurrentIteration(widget.m_memory.m_notifyTimes);
      updateNotifyTimes();
    });
  }

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    return WillPopScope(onWillPop: () async {onUpdate(context); return true;}, child:
      Scaffold(body: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: ListView(shrinkWrap: true, children: <Widget>[

        const SizedBox(height: 30),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: const Text("Reminder frequency", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          DropdownButton(value: widget.m_memory.m_testFrequecy, onChanged: (String? selectedValue) => onFrequencyDropDownChanged(selectedValue), items: const [
              DropdownMenuItem(value: "Never", child: Text("Never", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Rare", child: Text("Rare", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Occasionally", child: Text("Occasionally", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Frequently", child: Text("Frequently", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Custom", child: Text("Custom", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center))
            ],
        ))),

        const SizedBox(height: 30),

        Visibility(visible: widget.m_memory.m_testFrequecy != "Never" && widget.m_memory.m_testFrequecy != "Custom", child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 190, child: ListView(physics: const NeverScrollableScrollPhysics(), children: <Widget>[
          Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 50, child: Text("Iteration goal: " + widget.m_notificationCountGoal.toString(), style: const TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

          Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 30, child:
            Slider(value: widget.m_notificationCountGoal.toDouble(), min: 0, max: 25, onChanged: (newValue) => onNotificationCountGoalSliderChanged(newValue.toInt())
          ))),

          const SizedBox(height: 30),

          Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 50, child: Text("Start iteration: " + widget.m_notificationStartGoal.toString(), style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left))),

          Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 30, child:
            Slider(value: widget.m_notificationStartGoal.toDouble(), min: 0, max: widget.m_notificationCountGoal.toDouble(), onChanged: (newValue) => onCurrentIterationSliderChanged(newValue.toInt())
          ))),
        ]),
        )),

        Center(child: Visibility(visible: widget.m_memory.m_testFrequecy == "Custom", child: Column(children: [

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 50, child: Row(children: [
            const Text("Notifications: ", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left),
            TextButton(onPressed: () => onAddCustomNotification(), child: const Text("+", style: TextStyle(fontSize: 30, color: Colors.blue))),
          ])),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            ListView.builder(itemCount: widget.m_memory.m_notifyTimes.length, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, scrollDirection: Axis.vertical,  itemBuilder: (context, i) => genCustomNotificationWidget(context, i))
          )
        ]))),

        const SizedBox(height: 30),

        Visibility(visible: widget.m_memory.m_testFrequecy != "Never", child: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.7 + 125, child:
            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 50, child:
                const Text("Graph Timescale:", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)
              )),

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 30, child:
                Slider(value: widget.m_graphViewIterationsCount.toDouble(), min: 0, max: widget.m_memory.m_notifyTimes.length.toDouble(), onChanged: (newValue) => onGraphViewIterationsSliderChanged(newValue.toInt())
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
                    borderData: FlBorderData(border:
                      const Border(left: BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid, strokeAlign: StrokeAlign.inside), bottom: BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid, strokeAlign: StrokeAlign.inside))
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
                      enabled: false,
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 600),
                  swapAnimationCurve: Curves.fastOutSlowIn,
                ),
              ),
            ],),
        )),

        const SizedBox(height: 10),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: () => onCancel(context), child: const Text("Cancel", style: TextStyle(fontSize: 30, color: Colors.blue))),

          TextButton(onPressed: () => onUpdate(context), child: const Text("Update", style: TextStyle(fontSize: 30, color: Colors.blue)))
        ]),

        const SizedBox(height: 10),
       ])
    )));
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
    if(notifyTimes.isEmpty || widget.m_graphViewIterationsCount == 0)
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
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, 4, 1800000);
    }
    else if (widget.m_memory.m_testFrequecy == "Occasionally")
    {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, 3, 1200000);
    }
    else if (widget.m_memory.m_testFrequecy == "Frequently")
    {
      widget.m_memory.m_notifyTimes = genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, 2, 900000);
    }
    else if(widget.m_memory.m_testFrequecy == "Custom")
    {
      //Keep widget.m_memory.m_notifyTimes
      widget.m_notificationCountGoal = widget.m_memory.m_notifyTimes.length;
      widget.m_notificationStartGoal = getCurrentIteration(widget.m_memory.m_notifyTimes);
    }
    else
    {
      widget.m_memory.m_notifyTimes = [];
    }

    widget.m_graphViewIterationsCount = widget.m_memory.m_notifyTimes.length;

    updateGraphValues(widget.m_memory.m_notifyTimes);
  }

  void onCurrentIterationSliderChanged(int newValue)
  {
    setState(()
    {
      widget.m_notificationStartGoal = newValue;
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

  void onNotificationCountGoalSliderChanged(int newValue)
  {
    setState(()
    {
      if(widget.m_notificationStartGoal > newValue)
      {
        widget.m_notificationStartGoal = newValue;
      }

      widget.m_notificationCountGoal = newValue;

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

  void onAddCustomNotification()
  {
    setState(()
    {
      widget.m_memory.m_notifyTimes.add(DateTime.now().millisecondsSinceEpoch);
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

  Widget genCustomNotificationWidget(BuildContext context, int iCustomNotification)
  {
    return SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
      Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.width * 0.7, child:
          TextButton(onPressed: () => onSelectCustomNotification(context, iCustomNotification), child:
            Text(epochMsToDate(widget.m_memory.m_notifyTimes[iCustomNotification]), style: const TextStyle(fontSize: 20, color: Colors.grey))
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
          TextButton(onPressed: () => onDeleteCustomNotification(iCustomNotification), child:
            const Text("X", style: TextStyle(fontSize: 30, color: Colors.grey))
          ),
        )
      ])
    );
  }

  void onSelectCustomNotification(BuildContext context, int iCustomNotification) async
  {
    DateTime? newDate = await showDatePicker(context: context, initialDate: DateTime.fromMillisecondsSinceEpoch(widget.m_memory.m_notifyTimes[iCustomNotification]), firstDate: DateTime.now(), lastDate: DateTime.fromMillisecondsSinceEpoch(8640000000000000));
    TimeOfDay? newTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if(newDate != null && newTime != null)
    {
      var dateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);
      setState(()
      {
        widget.m_memory.m_notifyTimes[iCustomNotification] = dateTime.millisecondsSinceEpoch;
        updateNotifyTimes();
      });
    }
  }

  void onDeleteCustomNotification(int iCustomNotification)
  {
    setState(()
    {
      widget.m_memory.m_notifyTimes.removeAt(iCustomNotification);
      updateNotifyTimes();
    });
  }

  String epochMsToDate(int epochMs)
  {
    var date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return date.toString();
  }

  List<int> genNotifyTimes(int iStart, int iMaxNotifications, double incFactor, int incTime)
  {
    List<int> values = [];
    //values.add(DateTime.now().millisecondsSinceEpoch + 30000);
    for(int i = iStart; i < iMaxNotifications; i++)
    {
      values.add(DateTime.now().millisecondsSinceEpoch + incTime * pow(incFactor, i).toInt());
    }
    return values;
  }

  int getCurrentIteration(List<int> notifyTimes)
  {
    if(notifyTimes.isEmpty)
    {
        return 0;
    }

    notifyTimes.sort((a, b) => a.compareTo(b));

    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    for(int i = 0; i < notifyTimes.length; i++)
    {
      if(currentTime < notifyTimes[i])
      {
        return i;
      }
    }

    return notifyTimes.length-1;
  }
}