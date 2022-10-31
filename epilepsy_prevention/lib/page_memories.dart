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

    const TextStyle titleTextStyle = TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.blue);
    final TextPainter textPainter = TextPainter(text: const TextSpan(text: "Memories", style: titleTextStyle), maxLines: 1, textDirection: TextDirection.ltr)..layout(minWidth: 0, maxWidth: double.infinity);
    
    return WillPopScope(onWillPop: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); return true;}, child: Scaffold(body:
      ListView(shrinkWrap: true, children: <Widget>[

        SizedBox(width: MediaQuery.of(context).size.width, height: textPainter.height * 2, child:
          Row(children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.1),
            SizedBox(width: MediaQuery.of(context).size.width * 0.6, child:
              const Text("Memories", style: titleTextStyle, textAlign: TextAlign.left)
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

  List<Widget> getMemoryWidgets()
  {
    List<Widget> widgets = <Widget>[];

    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        widgets.add(
          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,children: [
            SizedBox(width: MediaQuery.of(context).size.width * 0.7, child:
              TextButton(onPressed: () => onMemoryPressed(memory), child:
                Text(memory.m_question, style: const TextStyle(fontSize: 30.0, color: Colors.blue))
              )
            ),

            SizedBox(width: MediaQuery.of(context).size.width * 0.3, child:
              TextButton(onPressed: () => onMemoryTestPressed(memory), child:
                const Text("Test", style: TextStyle(fontSize: 30.0, color: Colors.blue))
              )
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.1)
          ])
        );
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