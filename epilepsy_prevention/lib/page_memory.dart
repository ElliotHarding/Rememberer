import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';

class PageMemory extends StatelessWidget
{
  PageMemory(this.m_memory);

  Memory m_memory;

  String m_notificationsFrequency = "Never";

  final m_questionTextController = TextEditingController();
  final m_answerTextController = TextEditingController();
  final m_wrongAnswersTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    m_questionTextController.text = m_memory.m_question;
    m_answerTextController.text = m_memory.m_answer;
    m_wrongAnswersTextController.text = m_memory.m_falseAnswers;

    return Scaffold(
        body: Column(children: <Widget>[

          const Spacer(),

          Column(children: [
            const Text("Question", style: TextStyle(fontSize: 30), textAlign: TextAlign.left),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search question',
              ),
              style: const TextStyle(fontSize: 30.0, color: Colors.black),
              controller: m_questionTextController,
            )
          ],),

          const Spacer(),

          Column(children: [
            const Text("Correct Answer", style: TextStyle(fontSize: 30, color: Colors.black), textAlign: TextAlign.left),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a answer',
              ),
              controller: m_answerTextController
            )
          ]),

          const Spacer(),
          
          StatefulBuilder(builder: (BuildContext context, StateSetter setState)
          {
            return Column(children: <Widget>
              [
                Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
                  const Text("Multi Choice: ", style: TextStyle(fontSize: 30, color: Colors.black), textAlign: TextAlign.center),
                  Checkbox(value: m_memory.m_bMultiChoice, onChanged: (bool? value){if(value != null){ setState(() {
                    m_memory.m_bMultiChoice = value;
                  }); }})
                ]
                ),

                Visibility(visible: m_memory.m_bMultiChoice,
                  child:  TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter wrong answers.',
                      ),
                      style: const TextStyle(fontSize: 30, color: Colors.black),
                      controller: m_wrongAnswersTextController
                  )
                ),

                const Spacer(),

                const Text("Reminder frequency", style: TextStyle(fontSize: 30), textAlign: TextAlign.left),

              DropdownButton(items: const [
                  DropdownMenuItem(child: Text("Never", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center), value: "Never"),
                  DropdownMenuItem(child: Text("Rare", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center), value: "Rare"),
                  DropdownMenuItem(child: Text("Occasional", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center), value: "Occasional"),
                  DropdownMenuItem(child: Text("Frequently", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center), value: "Frequently")
                )],
                value: m_notificationsFrequency,
                onChanged: (String? selectedValue) {
                  setState((){if(selectedValue != null){ m_notificationsFrequency = selectedValue;}});
                }
              ),
              ]);
          }),

          const Spacer()

          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[

            TextButton(onPressed: (){

              var box = Database().getMemoryBox();
              if(box != null)
              {
                box.delete(m_memory.key);
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) => PageHome()));
            }, child: const Text("Delete", style: TextStyle(fontSize: 30, color: Colors.black))),

            TextButton(onPressed: () async {

              var box = Database().getMemoryBox();
              if(box != null)
              {
                m_memory.m_question = m_questionTextController.text;
                m_memory.m_answer = m_answerTextController.text;
                m_memory.m_falseAnswers = m_wrongAnswersTextController.text;
                box.add(m_memory);
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
            }, child: const Text("Add", style: TextStyle(fontSize: 30, color: Colors.black)))
          ]),

          const Spacer()
        ]
        ),
    );
  }
}