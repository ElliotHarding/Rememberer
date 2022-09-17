import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_memory.dart';
import 'package:epilepsy_prevention/Memory.dart';
import 'package:epilepsy_prevention/page_memories.dart';

class PageHome extends StatefulWidget
{
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome>
{
  bool? m_bAppEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Text( "Enable: ", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
          Checkbox(value: m_bAppEnabled, onChanged: (bool? value){setState((){m_bAppEnabled = value;});})
          ]
        ),

        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemory(Memory("", "", ""))));
          }, child: const Text("Add new entry"))
        ]
        ),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
          }, child: const Text("View Memories"))
        ]
        ),
      ],)
    );
  }
}