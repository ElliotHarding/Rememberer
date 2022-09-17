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