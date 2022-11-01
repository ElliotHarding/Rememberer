import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/display.dart';
import 'package:flutter/services.dart';
import 'notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Used by setPreferredOrientations and something else...

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  //Setup database stuff
  var database = Database();
  await database.init();

  //Setup notifications stuff
  var notifications = Notifications();
  await notifications.init();

  //Setup display settings
  Display().init();

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
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //set desired text scale factor here
                child: child!,
              );
            },
            home: PageTest(mem, const PageHome())
        );
      }
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (BuildContext context, Widget? child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //set desired text scale factor here
            child: child!,
          );
        },
        home: const PageHome()
    );
  }
}