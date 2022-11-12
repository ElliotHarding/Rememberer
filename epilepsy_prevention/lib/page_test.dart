import 'package:epilepsy_prevention/page_memories.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_testResult.dart';
import 'package:epilepsy_prevention/notifications.dart';
import 'dart:math';
import 'package:epilepsy_prevention/display.dart';

class PageTest extends StatelessWidget
{
  PageTest(this.m_memory, this.m_returnScreen);

  StatefulWidget m_returnScreen;

  Memory m_memory;

  final m_answerTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    m_answerTextController.text = "";
    return Scaffold(
      body: ListView(shrinkWrap: true, children: <Widget>[

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child:
          SizedBox(width: MediaQuery.of(context).size.width * 0.8, child:
            Text(m_memory.m_question, style: Display.largeTextStyle, textAlign: TextAlign.center)
        )),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child:
          Visibility(visible: !m_memory.m_bMultiChoice, child:
            SizedBox(width: MediaQuery.of(context).size.width * 0.8, child:
              Text("Answer", style: Display.largeTextStyle, textAlign: TextAlign.left)
            )
        )),

        Center(child:
          Visibility(visible: !m_memory.m_bMultiChoice, child:
            IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
              TextField(
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a answer'),
                style: Display.largeTextStyleBlack,
                controller: m_answerTextController,
                maxLines: null
              )
        )))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Center(child:
         Visibility(visible: !m_memory.m_bMultiChoice, child:
          TextButton(onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, m_answerTextController.text.toLowerCase() == m_memory.m_answer.toLowerCase(), m_returnScreen)));
              }, child: Text("Guess", style: Display.largeTextStyle, textAlign: TextAlign.center)
          )
        )),

        Center(child:
          Visibility(visible: m_memory.m_bMultiChoice, child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
            ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), scrollDirection: Axis.vertical, children: getMultiChoiceAnswers(context))
        ))),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories())); }, child:
            Text("Memories", style: Display.miniNavButtonTextStyle)
          ),

          const Spacer(),

          TextButton(onPressed: () async { Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome())); }, child:
            Text("Home", style: Display.miniNavButtonTextStyle)
          ),

          const Spacer()
        ]),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),
      ]
      ),
    );
  }

  List<Widget> getMultiChoiceAnswers(BuildContext context)
  {
    List<Widget> widgets = <Widget>[];

    if(m_memory.m_falseAnswers.length > 0)
    {
      int iAnswer = Random().nextInt(m_memory.m_falseAnswers.length);

      for(int i = 0; i < m_memory.m_falseAnswers.length; i++)
      {
        if(i == iAnswer)
        {
          widgets.add(genMultiChoiceOption(context, m_memory.m_answer, true));
        }

        widgets.add(genMultiChoiceOption(context, m_memory.m_falseAnswers[i], false));
      }
    }
    else
    {
      widgets.add(genMultiChoiceOption(context, m_memory.m_answer, true));
    }

    return widgets;
  }

  Widget genMultiChoiceOption(BuildContext context, String option, bool success)
  {
    return SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Column(children: [

      const SizedBox(height: 20),

      Row(children: [

        SizedBox(width: MediaQuery.of(context).size.width * 0.75, child:
          Text(option, style: Display.normalTextStyle, textAlign: TextAlign.left)
        ),

        Checkbox(value: false, onChanged: (bool? value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, success, m_returnScreen)));
        }),
      ]),

      const SizedBox(height: 20)
      ])
    );
  }
}