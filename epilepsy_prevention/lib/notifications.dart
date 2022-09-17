import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Timezone imports
import 'package:timezone/data/latest_all.dart' as timeZone;
import 'package:timezone/timezone.dart' as timeZone;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:epilepsy_prevention/memory.dart';

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

  Future<void> init() async
  {
    setupTimezoneStuff();

    if(!(await isNotificationPermissionGranted()))
    {
      await requestNotificationPermissions();
    }

    //App launched by notification?
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await _m_flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      _m_selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    }

    //Initialize local notifications plugin
    await _m_flutterLocalNotificationsPlugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onSelectNotification: (String? payload) async {
          _m_selectedNotificationPayload = payload;
        });
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

  Future<void> scheduleNotification(Memory memory, int secondsFromNow, String channelId) async
  {
    await _m_flutterLocalNotificationsPlugin.zonedSchedule(
        Database().getAndIncrementChannelNumber(),
        'Time to remember!',
        memory.m_question,
        timeZone.TZDateTime.now(timeZone.local).add(const Duration(seconds: 1) * secondsFromNow),
        NotificationDetails(
            android: AndroidNotificationDetails(
                channelId, 'Memory notification channel',
                channelDescription: 'Memory notification channel')
        ),
        androidAllowWhileIdle: true,
        payload: memory.key.toString(),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  Future<void> removeNotification(String channelId) async
  {
    await _m_flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.deleteNotificationChannel(channelId);
  }
}