import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/Memory.dart';

class PageMemories extends StatelessWidget
{
  PageMemories({super.key});

  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Column(children: <Widget>
        [
        const Spacer(),

        ListView(children: getMemoryWidgets())
        ]
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
        widgets.add(Row(
          children: [
            TextButton(onPressed: (){
              log(memory.m_question);
            }, child: Text(memory.m_question))
          ],
        ));
      }
    }
    return widgets;
  }
}