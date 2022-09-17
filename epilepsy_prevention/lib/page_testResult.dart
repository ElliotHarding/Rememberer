import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';

class PageTestResult extends StatelessWidget
{
  PageTestResult(this.m_memory, this.m_bSuccess);

  Memory m_memory;
  bool m_bSuccess;

  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Column(children: <Widget>[

        const Spacer(),

        Text(m_bSuccess ? "Correct!" : "Wrong!", style: const TextStyle(fontSize: 10), textAlign: TextAlign.left),

        const Spacer(),

        Text(m_memory.m_question, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),

        const Spacer(),

        Text(m_memory.m_answer, style: const TextStyle(fontSize: 10), textAlign: TextAlign.left),

        const Spacer(),

        TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => PageHome()));
        }, child: const Text("Home")),
      ]
      )
    );
  }
}