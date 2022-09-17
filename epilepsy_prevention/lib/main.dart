import 'package:epilepsy_prevention/page_home.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Setup database stuff
  var database = Database();
  await database.init();

  //Setup notifications stuff
  var notifications = Notifications();
  notifications.init();

  //Run app
  runApp(App(notifications.getNotificationPayload()));
}

class App extends StatelessWidget
{
  App(this._m_notificationPayload);

  String? _m_notificationPayload;

  @override
  Widget build(BuildContext context)
  {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PageHome()
      );
  }
}