import 'package:epilepsy_prevention/page_home.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Timezone imports
import 'package:timezone/data/latest_all.dart' as timeZone;
import 'package:timezone/timezone.dart' as timeZone;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Setup database stuff
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(MemoryAdapter());
  var database = Database();
  await database.init();

  setupTimezoneStuff();

  //App launched by notification?
  String? selectedNotificationPayload;
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
  }

  //Initalize local notifications plugin
  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')),
      onSelectNotification: (String? payload) async {
        selectedNotificationPayload = payload;
      });

  //Check if notification permissions are granted, if not ask.
  bool? notificationPermissionGranted = false;
  if(!(await isAndroidNotificationPermissionGranted()))
  {
    notificationPermissionGranted = await requestPermissionsForAndroid();
  }

  //Run app
  runApp(const App());
}

class App extends StatelessWidget
{
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PageHome()
      );
  }
}

Future<bool> isAndroidNotificationPermissionGranted() async {
  return await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.areNotificationsEnabled() ??
      false;
}

Future<bool?> requestPermissionsForAndroid() async
{
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();

  return await androidImplementation?.requestPermission();
}

Future<void> setupTimezoneStuff() async
{
  timeZone.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  timeZone.setLocalLocation(timeZone.getLocation(timeZoneName!));
}