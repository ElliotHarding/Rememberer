import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Timezone imports
import 'package:timezone/data/latest_all.dart' as timeZone;
import 'package:timezone/timezone.dart' as timeZone;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

import 'package:epilepsy_prevention/memory.dart';

class Notifications
{
  static final Notifications m_notifications = Notifications._internal();
  factory Notifications()
  {
    return m_notifications;
  }
  Notifications._internal();

  static FlutterLocalNotificationsPlugin _m_flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static String? m_selectedNotificationPayload;

  void init() async
  {
    if(!(await isNotificationPermissionGranted()))
    {
      await requestNotificationPermissions();
    }

    //App launched by notification?
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await _m_flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      m_selectedNotificationPayload = notificationAppLaunchDetails!.payload;
    }

    //Initialize local notifications plugin
    await m_flutterLocalNotificationsPlugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
        onSelectNotification: (String? payload) async {
          m_selectedNotificationPayload = payload;
        });
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

  Future<void> scheduleNotification(Memory memory, int secondsFromNow, int id) async
  {
    await _m_flutterLocalNotificationsPlugin.schedule(
        id,
        'Time to remember!',
        memory.m_question,
        timeZone.TZDateTime.now(timeZone.local).add(const Duration(seconds: 1) * secondsFromNow),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description')),
        payload: memory.key,
        androidAllowWhileIdle: true);
  }
}