import 'package:epilepsy_prevention/page_home.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'dart:math';
import 'package:epilepsy_prevention/memory.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_test.dart';

//Timezone imports
import 'package:timezone/data/latest_all.dart' as timeZone;
import 'package:timezone/timezone.dart' as timeZone;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class Notifications
{
  static final Notifications _m_notifications = Notifications._internal();
  factory Notifications()
  {
    return _m_notifications;
  }
  Notifications._internal();

  static final FlutterLocalNotificationsPlugin _m_flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static String? _m_selectedNotificationPayload;
  static BehaviorSubject<String?> _m_selectedNotificationSubject = BehaviorSubject<String?>();
  static var _m_currentContext = null;

  Future<void> init() async
  {
    setupTimezoneStuff();

    if(!(await isNotificationPermissionGranted()))
    {
      bool? result = await requestNotificationPermissions();
      if(result == true)
        {
          int x = 0;
        }
    }

    //App launched by notification?
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await _m_flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      _m_selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    }

    //Initialize local notifications plugin
    await _m_flutterLocalNotificationsPlugin.initialize(const InitializationSettings(android:
      AndroidInitializationSettings('@mipmap/ic_launcher')),
        onSelectNotification: (String? payload) async {
          _m_selectedNotificationPayload = payload;
          _m_selectedNotificationSubject.add(payload);
        }
      );

    initNotificationActionListener();
  }

  static void initNotificationActionListener()
  {
    _m_selectedNotificationSubject.stream.listen((String? memoryKey) async {
      if(memoryKey != null) {
        var database = Database();
        int? keyValue = int.tryParse(memoryKey);
        if(keyValue != null)
        {
          Memory? mem = database.getMemoryWithId(keyValue);
          if (mem != null)
          {
            if(_m_currentContext != null)
            {
              Notifications._m_selectedNotificationSubject.add(null);
              Navigator.push(_m_currentContext, MaterialPageRoute(builder: (context) => PageTest(mem, const PageHome())));
            }
          }
        }
      }
    });
  }

  static void setupNotificationActionListener(BuildContext context)
  {
    _m_currentContext = context;
  }

  String? getNotificationPayload()
  {
    return _m_selectedNotificationPayload;
  }

  Future<void> setupTimezoneStuff() async
  {
    timeZone.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    timeZone.setLocalLocation(timeZone.getLocation(timeZoneName!));
  }

  Future<bool> isNotificationPermissionGranted() async {
    return await _m_flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled() ??
        false;
  }

  Future<bool?> requestNotificationPermissions() async
  {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
    _m_flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    return await androidImplementation?.requestPermission();
  }

  Future<void> scheduleNotifications(int key, String question, List<int> triggerTimesMs) async
  {
    for (int notifyTime in triggerTimesMs)
    {
       await scheduleNotification(key, question, notifyTime, key.toString() + "-" + notifyTime.toString());
    }
  }

  Future<void> scheduleNotification(int key, String question, int triggerTimeMs, String channelId) async
  {
    await _m_flutterLocalNotificationsPlugin.zonedSchedule(
        Database().getAndIncrementChannelNumber(),
        'Time to remember!',
        question,
        timeZone.TZDateTime.fromMillisecondsSinceEpoch(timeZone.local, triggerTimeMs),
        NotificationDetails(android: AndroidNotificationDetails(channelId, channelId, channelDescription: channelId)),
        androidAllowWhileIdle: true,
        payload: key.toString(),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> removeNotifications(int key, List<int> triggerTimesSeconds) async
  {
    for (int notifyTime in triggerTimesSeconds)
    {
      await removeNotification(key.toString() + "-" + notifyTime.toString());
    }
  }

  Future<void> removeNotification(String channelId) async
  {
    await _m_flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }

  List<MemoryNotification> genNotifyTimes(int iStart, int iMaxNotifications, double incFactor, int incTime)
  {
    List<MemoryNotification> values = [];
    for(int i = iStart; i < iMaxNotifications; i++)
    {
      int notifyDelay = incTime * pow(incFactor, i).toInt();
      if(notifyDelay > 31556926000)
      {
          break;
      }
      values.add(MemoryNotification(DateTime.now().millisecondsSinceEpoch + notifyDelay, false));
    }
    return values;
  }

  String epochMsToDate(int epochMs)
  {
    var date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    var hour = date.hour.toString();
    if(hour.length == 1)
    {
      hour = "0" + hour;
    }
    var minute = date.minute.toString();
    if(minute.length == 1)
    {
      minute = "0" + minute;
    }
    return date.day.toString() + "/" + date.month.toString() + "/" + date.year.toString().substring(2) + " " + hour + ":" + minute;
  }

}