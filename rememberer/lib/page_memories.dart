import 'page_home.dart';
import 'page_test.dart';
import 'package:flutter/material.dart';
import 'memory.dart';
import 'page_memory.dart';
import 'notifications.dart';
import 'display.dart';

class PageMemories extends StatefulWidget
{
  PageMemories({Key? key}) : super(key: key);

   @override
  State<PageMemories> createState() => PageMemoriesState();
}

class PageMemoriesState extends State<PageMemories>
{
  List<Widget> m_memoryWidgets = [];

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    m_memoryWidgets = getMemoryWidgets();

    final double titlePadding = MediaQuery.of(context).size.width * 0.1;
    
    return WillPopScope(onWillPop: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); return true;}, child: Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        Row(children: [
          Padding(padding: EdgeInsets.all(titlePadding), child:
            SizedBox(width: MediaQuery.of(context).size.width * 0.5, child:
              Align(alignment: Alignment.centerLeft, child: Text("Memories", style: Display.titleTextStyle, textAlign: TextAlign.left))
          )),

          Padding(padding: EdgeInsets.fromLTRB(0, titlePadding, titlePadding, titlePadding), child: SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
            TextButton(onPressed: () => gotoAddNewMemory(), child: Align(alignment: Alignment.centerRight, child: SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
              Text("📝⁺", style: Display.titleTextStyle, textAlign: TextAlign.right)
            ))),
          ))
        ]),

        Visibility(visible: m_memoryWidgets.isEmpty, child: Text("No Memories Yet!", style: Display.largeTextStyle, textAlign: TextAlign.center,)),

        ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: m_memoryWidgets),
      ])
      )
    );
   }

  List<Widget> getMemoryWidgets()
  {
    List<Widget> widgets = <Widget>[];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        widgets.add(Row(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),

          SizedBox(width: MediaQuery.of(context).size.width * 0.7, child:
            Text(memory.m_question, style: Display.listItemTextStyle, textAlign: TextAlign.left)
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.1, child: Column(children: [
            TextButton(onPressed: () => onMemoryPressed(memory), child:
              Text("⚙", style: Display.listItemTextStyle)
            ),

            TextButton(onPressed: () => onMemoryTestPressed(memory), child:
              Text("?", style: Display.listItemTextStyle)
            )
          ])
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.1, child:
            TextButton(onPressed: () => onDeletePressed(memory), child:
              Text("🗑", style: Display.listItemTextStyle)
            )
          )
        ]));

        widgets.add(const SizedBox(height: 15));
      }
    }
    return widgets;
  }

  void gotoAddNewMemory() async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory())));
    setState(() {
      m_memoryWidgets = getMemoryWidgets();
    });
  }

  void onMemoryPressed(Memory memory) async
  {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(memory)));
    setState(() {
      m_memoryWidgets = getMemoryWidgets();
    });
  }

  void onMemoryTestPressed(Memory memory)
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(memory, PageMemories())));
  }

  void onDeletePressed(Memory memory)
  {
    showDialog(context: context, builder: (context) => promptDialog("Delete Memory?", "Are you sure you want to delete this memory?", "Yes", "No", memory));
  }

  AlertDialog promptDialog(String title, String content, String confirmText, String denyText, Memory memory)
  {
    return AlertDialog(title: Text(title, style: Display.largeTextStyle), content: Text(content, style: Display.normalTextStyle), actions: <Widget>[
      TextButton(onPressed: () => onKeepMemory(), child:
        Text(denyText, style: Display.miniNavButtonTextStyle)
      ),

      const SizedBox(width: 10),

      TextButton(onPressed: () => onDeleteMemoryConfirmed(memory), child:
        Text(confirmText, style: Display.miniNavButtonTextStyle)
      ),
    ],);
  }

  void onKeepMemory()
  {
    Navigator.of(context).pop();
  }

  void onDeleteMemoryConfirmed(Memory memory)
  {
    //Clear notifications
    Notifications().removeNotifications(memory.key, memory.getNotifyTimes());

    Database().deleteMemory(memory.key);

    Navigator.of(context).pop();

    setState(() {
      m_memoryWidgets = getMemoryWidgets();
    });
  }
}