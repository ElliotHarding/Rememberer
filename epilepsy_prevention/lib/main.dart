import 'package:epilepsy_prevention/page_home.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(MemoryAdapter());
  var database = Database();
  await database.init();
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
