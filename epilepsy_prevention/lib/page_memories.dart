import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/notifications.dart';

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

    const String titleString = "Memories";
    const TextStyle titleTextStyle = TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue);
    final double titleHeight = getTextHeight(titleString, titleTextStyle) * 2;
    
    return WillPopScope(onWillPop: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); return true;}, child: Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        SizedBox(width: MediaQuery.of(context).size.width, height: titleHeight, child:
          Row(children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.1),
            SizedBox(width: MediaQuery.of(context).size.width * 0.6, child:
              const Text(titleString, style: titleTextStyle, textAlign: TextAlign.left)
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
              TextButton(onPressed: () => gotoAddNewMemory(), child: const Align(alignment: Alignment.centerRight, child:
                Text("+", style: titleTextStyle, textAlign: TextAlign.right)
              )),
            )
          ])
        ),

        ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: m_memoryWidgets),
      ])
      )
    );
   }

  double getTextHeight(String textStr, TextStyle textStyle)
  {
    return (TextPainter(text: TextSpan(text: textStr, style: textStyle), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity)).height;
  }

  List<Widget> getMemoryWidgets()
  {
    List<Widget> widgets = <Widget>[];

    const TextStyle memoryWidgetTextStyle = TextStyle(fontSize: 30.0, color: Colors.blue);

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        widgets.add(Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.05),

          SizedBox(width: MediaQuery.of(context).size.width * 0.6, child:
            Text(memory.m_question, style: memoryWidgetTextStyle, textAlign: TextAlign.left)
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.15, child:
            TextButton(onPressed: () => onMemoryPressed(memory), child:
              const Text("⚙", style: memoryWidgetTextStyle)
          )
          ),

          SizedBox(width: MediaQuery.of(context).size.width * 0.15, child:
            TextButton(onPressed: () => onMemoryTestPressed(memory), child:
              const Text("?", style: memoryWidgetTextStyle)
          )
          )
        ]));
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
}