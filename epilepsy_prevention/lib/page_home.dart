import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/page_settings.dart';
import 'package:epilepsy_prevention/page_upcomingNotifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memories.dart';
import 'package:epilepsy_prevention/page_overdueTests.dart';
import 'package:epilepsy_prevention/display.dart';

class PageHome extends StatefulWidget
{
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome>
{
  @override
  Widget build(BuildContext context) {

    Notifications.setupNotificationActionListener(context);

    final double screenHeight = MediaQuery.of(context).size.height - MediaQuery.of(context).viewPadding.top - MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      drawer: SizedBox(width: MediaQuery.of(context).size.width * 0.7, child: NavigationDrawer()),
      appBar: AppBar(),
      body: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child: ListView(physics: const NeverScrollableScrollPhysics(), children: <Widget>[

          ])
      )
    );
  }
}

class NavigationDrawer extends StatelessWidget
{
  NavigationDrawer();

  Widget build(BuildContext context) => Drawer(
    child: Column(children: [
      header(context),
      menuPages(context)
    ],)
  );

  Widget header(BuildContext context) => Container(
    padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.05),
  );

  Widget menuPages(BuildContext context) => Wrap(runSpacing: 20, children: [
    ListTile(leading: SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Text("🏠", style: Display.menuPageTextStyle)), title: Text("Home", style: Display.menuPageTextStyle,), onTap: () => {Navigator.pop(context)},),
    ListTile(leading: SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Text("📝⁺", style: Display.menuPageTextStyle)), title: Text("New Memory", style: Display.menuPageTextStyle), onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())))},),
    ListTile(leading: SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Text("📝", style: Display.menuPageTextStyle)), title: Text("Memories", style: Display.menuPageTextStyle), onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()))},),
    ListTile(leading: SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Text("🕑", style: Display.menuPageTextStyle)), title: Text("Overdue Tests", style: Display.menuPageTextStyle), onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const PageOverdueTests()))},),
    ListTile(leading: SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Text("🔔", style: Display.menuPageTextStyle)), title: Text("Notifications", style: Display.menuPageTextStyle), onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const PageUpcomingNotifications()))},),
    ListTile(leading: SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Text("⚙", style: Display.menuPageTextStyle)), title: Text("Settings", style: Display.menuPageTextStyle), onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => const PageSettings()))},)
  ],);
}