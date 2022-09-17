import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_testResult.dart';

class PageTest extends StatelessWidget
{
  PageTest(this.m_memory);

  Memory m_memory;

  final m_answerTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    m_answerTextController.text = "";
    return Scaffold(
      body: Column(children: <Widget>[

        const Spacer(),

        Text(m_memory.m_question, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),

        const Spacer(),

        const Text("Answer", style: TextStyle(fontSize: 10), textAlign: TextAlign.left),

        Visibility(visible: !m_memory.m_bMultiChoice,
            child:  Column(children: <Widget>
            [
              TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a answer',
                ),
                controller: m_answerTextController
              ),

              TextButton(onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, m_answerTextController.text == m_memory.m_answer)));
              }, child: const Text("Guess"))
            ])
        ),

        Visibility(visible: m_memory.m_bMultiChoice,
            child: ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: getMultiChoiceAnswers(context))
        ),

        const Spacer(),

        TextButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => PageHome()));
        }, child: const Text("Home")),
      ]
      ),
    );
  }

  List<Widget> getMultiChoiceAnswers(BuildContext context)
  {
    List<Widget> widgets = <Widget>[];

    //Todo randomize correct answer order, and split false answers
    List<String> options = <String>[];
    options.add(m_memory.m_answer);
    options.add(m_memory.m_falseAnswers);

    for(String option in options)
    {
      widgets.add(Row(
        children: [
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, option == m_memory.m_answer)));
          }, child: Text(option))
        ],
      ));
    }

    return widgets;
  }
}