import 'package:flutter/material.dart';
import 'memory.dart';
import 'display.dart';
import 'notifications.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PageMemoryReminders extends StatefulWidget
{
  PageMemoryReminders({required this.m_memory, Key? key}) : super(key: key);

  Memory m_memoryBefore = Memory();
  Memory m_memory;

  //Notification gen vars
  int m_notificationStartGoal = 0;
  int m_notificationCountGoal = 0;
  int m_configureTimeFrequency = 120000;
  int m_configureIncrement = 3;

  //Graph stuff
  int m_graphMaxTime = 0;
  int m_graphMinTime = 0;
  int m_graphViewIterationsCount = 0;
  List<ScatterSpot> m_graphDataPoints = [];
  double m_graphTimeInterval = 1;

  //New fixed time
  TimeOfDay m_fixedNotifyTime = TimeOfDay.now();

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

      //If first time generating notify times, auto set up some
      if(Database().getMemoryWithId(widget.m_memory.key) == null)
      {
        widget.m_notificationStartGoal = 0;
        widget.m_notificationCountGoal = 5;
        widget.m_configureIncrement = 4;
        widget.m_configureTimeFrequency = 1800000;
        widget.m_memory.m_testFrequecy = "Configure";
        widget.m_fixedNotifyTime = TimeOfDay.now();
        updateNotifyTimes();
      }

      widget.m_notificationCountGoal = widget.m_memory.m_notifications.length;

      if(widget.m_memory.m_notifications.length > 0)
      {
        DateTime notifyTime = DateTime.fromMillisecondsSinceEpoch(widget.m_memory.m_notifications[0].m_notifyTime);
        widget.m_fixedNotifyTime = TimeOfDay(hour: notifyTime.hour, minute: notifyTime.minute);
      }
      else
      {
        widget.m_fixedNotifyTime = TimeOfDay.now();
      }

      widget.m_notificationStartGoal = getCurrentIteration(widget.m_memory.getNotifyTimes());
      updateNotifyTimes();
    });
  }

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    return WillPopScope(onWillPop: () async {onUpdate(); return true;}, child:
      Scaffold(body: ListView(shrinkWrap: true, children: <Widget>[

        Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child:
          Text("Reminder frequency", style: Display.largeTextStyle, textAlign: TextAlign.left),
        ),

        Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 0, 0, 0), child:
          DropdownButton(value: widget.m_memory.m_testFrequecy, onChanged: (String? selectedValue) => onFrequencyDropDownChanged(selectedValue), items: [
              DropdownMenuItem(value: "Never", child: Text("Never", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Rare", child: Text("Rare", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Occasionally", child: Text("Occasionally", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Frequently", child: Text("Frequently", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Custom", child: Text("Custom", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Fixed", child: Text("Fixed", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center)),
              DropdownMenuItem(value: "Configure", child: Text("Configure", style: Display.listItemTextStyleBlack, textAlign: TextAlign.center))
          ],
        )),

        Visibility(visible: widget.m_memory.m_testFrequecy != "Never" && widget.m_memory.m_testFrequecy != "Custom" && widget.m_memory.m_testFrequecy != "Fixed", child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Column(children: <Widget>[

          Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Iteration goal: " + widget.m_notificationCountGoal.toString(), style: Display.largeTextStyle, textAlign: TextAlign.left),
          )),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            Slider(value: widget.m_notificationCountGoal.toDouble(), min: 0, max: widget.m_memory.m_testFrequecy == "Fixed" ? 100 : 25, onChanged: (newValue) => onNotificationCountGoalSliderChanged(newValue.toInt())
          )),

          Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Start iteration: " + widget.m_notificationStartGoal.toString(), style: Display.largeTextStyle, textAlign: TextAlign.left),
          )),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            Slider(value: widget.m_notificationStartGoal.toDouble(), min: 0, max: widget.m_notificationCountGoal.toDouble(), onChanged: (newValue) => onCurrentIterationSliderChanged(newValue.toInt())
          )),
        ]),
        )),

        Center(child: Visibility(visible: widget.m_memory.m_testFrequecy == "Custom", child: Column(children: [

          Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child: Row(children: [
            Text("Notifications: ", style: Display.largeTextStyle, textAlign: TextAlign.left),
            TextButton(onPressed: () => onAddCustomNotification(), child: Text("📝⁺", style: Display.largeTextStyle)),
          ])),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            ListView.builder(itemCount: widget.m_memory.m_notifications.length, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, scrollDirection: Axis.vertical,  itemBuilder: (context, i) => genCustomNotificationWidget(i))
          )
        ]))),

        Center(child: Visibility(visible: widget.m_memory.m_testFrequecy == "Fixed", child: Column(children: [

          SizedBox(width: MediaQuery.of(context).size.width * 0.8, child:
            TextButton(onPressed: () => onSelectFixedNotification(), child:
              Text(widget.m_fixedNotifyTime.toString(), style: Display.listItemTextStyle)
            ),
          ),

        ]))),

        Visibility(visible: widget.m_memory.m_testFrequecy == "Configure", child: Column(children: <Widget>[

          Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Time: " + widget.m_configureTimeFrequency.toString(), style: Display.largeTextStyle, textAlign: TextAlign.left),
          )),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            Slider(value: widget.m_configureTimeFrequency.toDouble(), min: 10000, max: 9999999, onChanged: (newValue) => onConfigureTimeFrequencyChanged(newValue.toInt())
          )),

          Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Increment: " + widget.m_configureIncrement.toString(), style: Display.largeTextStyle, textAlign: TextAlign.left),
          )),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            Slider(value: widget.m_configureIncrement.toDouble(), min: 1, max: 10, onChanged: (newValue) => onConfigureIncrementFactorChanged(newValue.toInt())
          )),
        ]),
        ),

        Visibility(visible: widget.m_memory.m_testFrequecy != "Never" && widget.m_memory.m_testFrequecy != "Fixed", child:
            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [

              Padding(padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width * 0.05, 30, 0, 0), child:
                Text("Graph Timescale:", style: Display.largeTextStyle, textAlign: TextAlign.left),
              ),

              Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
                Slider(value: widget.m_graphViewIterationsCount.toDouble(), min: 0, max: widget.m_memory.m_notifications.length.toDouble(), onChanged: (newValue) => onGraphViewIterationsSliderChanged(newValue.toInt())
              ))),

              const SizedBox(height: 30),

              SizedBox(width: MediaQuery.of(context).size.width * 0.95, height: MediaQuery.of(context).size.height * 0.7, child:
                ScatterChart(
                  ScatterChartData(
                    scatterSpots: widget.m_graphDataPoints,
                    minX: 1,
                    maxX: widget.m_graphViewIterationsCount.toDouble(),
                    minY: widget.m_graphMinTime.toDouble(),
                    maxY: widget.m_graphMaxTime.toDouble(),
                    borderData: FlBorderData(border:
                      const Border(left: BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid), bottom: BorderSide(color: Colors.black, width: 1, style: BorderStyle.solid))
                    ),
                    gridData: FlGridData(
                      show: false,
                    ),
                    titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: Display.graphTitleSpaceReserved, getTitlesWidget: getIterationIndexValues, interval: 1)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: Display.graphTitleSpaceReserved, getTitlesWidget: getDateIndexValues, interval: widget.m_graphTimeInterval)),
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
        ),

        const SizedBox(height: 30),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () => onCancel(), child: Text("Cancel", style: Display.miniNavButtonTextStyle)),

          const Spacer(),

          TextButton(onPressed: () => onUpdate(), child: Text("Update", style: Display.miniNavButtonTextStyle)),

          const Spacer()
        ]),

        const SizedBox(height: 10),
       ])
    ));
  }

  Widget getDateIndexValues(double value, TitleMeta meta)
  {
    String timeStr;

    var minutes = value.toInt() / 60000;
    if(minutes < 120 && minutes > -120)
    {
        timeStr = minutes.toInt().toString() + " M";
    }
    else
    {
      var hours = value.toInt() / 3600000;
      if(hours < 48 && hours > -48)
      {
        timeStr = hours.toInt().toString() + " H";
      }
      else
      {
        var days = hours / 24;
        timeStr = days.toInt().toString() + " D";
      }
    }

    return SideTitleWidget(axisSide: meta.axisSide, child:
      Text(timeStr, style: Display.graphIndexStyle)
    );
  }

  Widget getIterationIndexValues(double value, TitleMeta meta)
  {
    return SideTitleWidget(axisSide: meta.axisSide, child:
      Text(value.toInt().toString(), style: Display.graphIndexStyle)
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

    widget.m_graphTimeInterval = widget.m_graphMaxTime / 10;
    widget.m_graphDataPoints = graphData;
  }

  //Must be called inside setState!
  void updateNotifyTimes()
  {
    if (widget.m_memory.m_testFrequecy == "Rare")
    {
      widget.m_memory.m_notifications = Notifications().genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, 4, 1800000);
      widget.m_notificationCountGoal = widget.m_memory.m_notifications.length + widget.m_notificationStartGoal;
    }
    else if (widget.m_memory.m_testFrequecy == "Occasionally")
    {
      widget.m_memory.m_notifications = Notifications().genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, 3, 1200000);
      widget.m_notificationCountGoal = widget.m_memory.m_notifications.length + widget.m_notificationStartGoal;
    }
    else if (widget.m_memory.m_testFrequecy == "Frequently")
    {
      widget.m_memory.m_notifications = Notifications().genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, 2, 900000);
      widget.m_notificationCountGoal = widget.m_memory.m_notifications.length + widget.m_notificationStartGoal;
    }
    else if(widget.m_memory.m_testFrequecy == "Custom")
    {
      //Keep widget.m_memory.m_notifyTimes
      widget.m_notificationStartGoal = getCurrentIteration(widget.m_memory.getNotifyTimes());
      widget.m_notificationCountGoal = widget.m_memory.m_notifications.length;
    }
    else if(widget.m_memory.m_testFrequecy == "Configure")
    {
      widget.m_memory.m_notifications = Notifications().genNotifyTimes(widget.m_notificationStartGoal, widget.m_notificationCountGoal, widget.m_configureIncrement.toDouble(), widget.m_configureTimeFrequency);
      widget.m_notificationCountGoal = widget.m_memory.m_notifications.length + widget.m_notificationStartGoal;
    }
    else if(widget.m_memory.m_testFrequecy == "Fixed")
    {
      widget.m_memory.m_notifications.clear();

      final DateTime dateTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, widget.m_fixedNotifyTime.hour, widget.m_fixedNotifyTime.minute);
      int epochIncTime = 0;
      for(int i = 1; i < 30; i++)
      {
        widget.m_memory.m_notifications.add(MemoryNotification(dateTime.millisecondsSinceEpoch + epochIncTime, false));
        epochIncTime += DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + i, 0, 0, 0, 0, 0).millisecondsSinceEpoch;
      }
    }
    else
    {
      widget.m_memory.m_notifications = [];
    }

    widget.m_graphViewIterationsCount = widget.m_memory.m_notifications.length;

    updateGraphValues(widget.m_memory.getNotifyTimes());
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
      updateGraphValues(widget.m_memory.getNotifyTimes());
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

  void onConfigureTimeFrequencyChanged(int value)
  {
    setState(() {
      widget.m_configureTimeFrequency = value;

      updateNotifyTimes();
    });
  }

  void onConfigureIncrementFactorChanged(int value)
  {
    setState(() {
      widget.m_configureIncrement = value;

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
      widget.m_memory.m_notifications.add(MemoryNotification(DateTime.now().millisecondsSinceEpoch, false));
      updateNotifyTimes();
    });
  }

  void onCancel()
  {
    Navigator.pop(context, widget.m_memoryBefore);
  }

  void onUpdate()
  {
    Navigator.pop(context, widget.m_memory);
  }

  Widget genCustomNotificationWidget(int iCustomNotification)
  {
    return Row(children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.width * 0.4, child:
          TextButton(onPressed: () => onSelectCustomNotification(iCustomNotification), child:
            Text(Notifications().epochMsToDate(widget.m_memory.m_notifications[iCustomNotification].m_notifyTime), style: Display.listItemTextStyle)
          ),
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.1, child:
          TextButton(onPressed: () => onSelectCustomNotification(iCustomNotification), child:
            Text("⚙", style: Display.listItemTextStyle)
          )
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.1, child:
          TextButton(onPressed: () => onDeleteCustomNotification(iCustomNotification), child:
            Text("🗑", style: Display.listItemTextStyle)
          ),
        )
      ])
    ;
  }

  void onSelectCustomNotification(int iCustomNotification) async
  {
    DateTime? newDate = await showDatePicker(context: context, initialDate: DateTime.fromMillisecondsSinceEpoch(widget.m_memory.m_notifications[iCustomNotification].m_notifyTime), firstDate: DateTime.now(), lastDate: DateTime.fromMillisecondsSinceEpoch(8640000000000000));
    TimeOfDay? newTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if(newDate != null && newTime != null)
    {
      var dateTime = DateTime(newDate.year, newDate.month, newDate.day, newTime.hour, newTime.minute);
      setState(()
      {
        widget.m_memory.m_notifications[iCustomNotification].m_notifyTime = dateTime.millisecondsSinceEpoch;
        widget.m_memory.m_notifications[iCustomNotification].m_bHasBeenTested = dateTime.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch;
        updateNotifyTimes();
      });
    }
  }

  void onSelectFixedNotification() async
  {
    TimeOfDay? newTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if(newTime != null)
    {
      setState(()
      {
        widget.m_fixedNotifyTime = newTime;
        updateNotifyTimes();
      });
    }
  }

  void onDeleteCustomNotification(int iCustomNotification)
  {
    setState(()
    {
      widget.m_memory.m_notifications.removeAt(iCustomNotification);
      updateNotifyTimes();
    });
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