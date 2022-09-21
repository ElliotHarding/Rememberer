import 'package:epilepsy_prevention/page_memories.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_testResult.dart';
import 'package:epilepsy_prevention/notifications.dart';

class PageTest extends StatelessWidget
{
  PageTest(this.m_memory);

  Memory m_memory;

  final m_answerTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    Notifications.m_selectedNotificationSubject.stream.listen((String? memoryKey) async {
      if(memoryKey != null) {
        var database = Database();
        int? keyValue = int.tryParse(memoryKey);
        if(keyValue != null)
        {
          Memory? mem = database.getMemoryWithId(keyValue);
          if (mem != null) {
            Notifications.m_selectedNotificationSubject.add(null);
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTest(mem)));
          }
        }
      }
    });

    m_answerTextController.text = "";
    return Scaffold(
      body: Column(children: <Widget>[

        const Spacer(),

        Text(m_memory.m_question, style: const TextStyle(fontSize: 35, color: Colors.black), textAlign: TextAlign.center),

        const Spacer(),

        const Text("Answer", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center),

        Visibility(visible: !m_memory.m_bMultiChoice, child:
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a answer',
              ),
            controller: m_answerTextController
          )
        ),

        Visibility(visible: !m_memory.m_bMultiChoice, child:
          TextButton(onPressed: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, m_answerTextController.text == m_memory.m_answer, context)));
            }, child: const Text("Guess", style: TextStyle(fontSize: 30, color: Colors.black), textAlign: TextAlign.center)
          )
        ),

        Visibility(visible: m_memory.m_bMultiChoice,
            child: ListView(shrinkWrap: true, scrollDirection: Axis.vertical, children: getMultiChoiceAnswers(context))
        ),

        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              TextButton(onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemories()));
              },
                  child: const Text("Memories", style: TextStyle(fontSize: 30, color: Colors.black))),

              TextButton(onPressed: () async {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
              },
                  child: const Text("Home", style: TextStyle(fontSize: 30, color: Colors.black)))
            ]),

        const Spacer()
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => PageTestResult(m_memory, option == m_memory.m_answer, context)));
          }, child: Text(option))
        ],
      ));
    }

    return widgets;
  }
}