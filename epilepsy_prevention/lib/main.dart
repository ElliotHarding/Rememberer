import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/page_test.dart';
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
  await notifications.init();

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
    //Comming from notification
    if(_m_notificationPayload != null) {
      var database = Database();
      Memory? mem = database.getMemoryWithId(int.parse(_m_notificationPayload ?? "-1"));
      if (mem != null) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: PageTest(mem)
        );
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PageHome()
    );
  }
}