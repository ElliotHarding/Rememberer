import 'package:epilepsy_prevention/page_memories.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_testResult.dart';
import 'package:epilepsy_prevention/page_common.dart';

class PageTest extends StatelessWidget with BasePage
{
  PageTest(this.m_memory);

  Memory m_memory;

  final m_answerTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    BasePage.setupNotificationActionListener(context);

    m_answerTextController.text = "";
    return Scaffold(
      body: Column(children: <Widget>[

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: MediaQuery.of(context).size.height * 0.1, child:
          Text(m_memory.m_question, style: const TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center)
        ),

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width * 0.8, height: 50, child:
          const Text("Answer", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)
        ),

        Visibility(visible: !m_memory.m_bMultiChoice, child:
          IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            TextField(
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a answer'),
              style: const TextStyle(fontSize: 30, color: Colors.black),
              controller: m_answerTextController
            )
        ))),

        const Spacer(),

        Visibility(visible: !m_memory.m_bMultiChoice, child:
          TextButton(onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, m_answerTextController.text == m_memory.m_answer)));
            }, child: const Text("Guess", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center)
          )
        ),

        Visibility(visible: m_memory.m_bMultiChoice, child:
          ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: getMultiChoiceAnswers(context))
        ),

        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories())); }, child:
            const Text("Memories", style: TextStyle(fontSize: 30, color: Colors.blue))
          ),

          const Spacer(),

          TextButton(onPressed: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); }, child:
            const Text("Home", style: TextStyle(fontSize: 30, color: Colors.blue))
          ),

          const Spacer()
        ]),

        const Spacer()
      ]
      ),
    );
  }

  List<Widget> getMultiChoiceAnswers(BuildContext context)
  {
    List<Widget> widgets = <Widget>[];

    for(String option in m_memory.m_falseAnswers)
    {
      widgets.add(Row(children: [
          TextButton(onPressed: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, option == m_memory.m_answer))); }, child:
            Text(option)
          )
        ],
      ));
    }

    return widgets;
  }
}