import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';

class PageMemory extends StatelessWidget
{
  PageMemory(this.m_memory);

  Memory m_memory;

  bool m_bChangeNotifyTimes = false;

  final m_questionTextController = TextEditingController();
  final m_answerTextController = TextEditingController();
  final m_wrongAnswersTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    if(m_memory.m_notifyTimes.length == 0)
    {
      m_bChangeNotifyTimes = true;
    }

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
                  DropdownMenuItem(value: "Never", child: Text("Never", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                  DropdownMenuItem(value: "Rare", child: Text("Rare", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                  DropdownMenuItem(value: "Occasional", child: Text("Occasional", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center)),
                  DropdownMenuItem(value: "Frequently", child: Text("Frequently", style: TextStyle(fontSize: 25, color: Colors.black), textAlign: TextAlign.center))
                ],
                value: m_memory.m_testFrequecy,
                onChanged: (String? selectedValue) {
                  setState((){if(selectedValue != null){ m_memory.m_testFrequecy = selectedValue; m_bChangeNotifyTimes = true;}});
                }
              ),
              ]);
          }),

          const Spacer(),

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

                if(m_bChangeNotifyTimes)
                {
                  Notifications notifications = Notifications();

                  //Clear previous notifications
                  for(int notifyTime in m_memory.m_notifyTimes)
                  {
                      notifications.removeNotification(m_memory.key.toString() + "-" + notifyTime.toString());
                  }
                  m_memory.m_notifyTimes.clear();

                  if(m_memory.m_testFrequecy == "Rare")
                  {
                    int notifyTime = 60;
                    m_memory.m_notifyTimes.add(notifyTime);
                    await notifications.scheduleNotification(m_memory, notifyTime, 0, m_memory.key.toString() + "-" + notifyTime.toString());
                  }
                  else if(m_memory.m_testFrequecy == "Occasional")
                  {
                    int notifyTime = 30;
                    m_memory.m_notifyTimes.add(notifyTime);
                    await notifications.scheduleNotification(m_memory, notifyTime, 1, m_memory.key.toString() + "-" + notifyTime.toString());
                  }
                  else if(m_memory.m_testFrequecy == "Frequently")
                  {
                    int notifyTime = 1;
                    m_memory.m_notifyTimes.add(notifyTime);
                    await notifications.scheduleNotification(m_memory, notifyTime, 2, m_memory.key.toString() + "-" + notifyTime.toString());
                  }
                }

                box.add(m_memory);
              }

              Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
            }, child: const Text("Save", style: TextStyle(fontSize: 30, color: Colors.black)))
          ]),

          const Spacer()
        ]
        ),
    );
  }
}