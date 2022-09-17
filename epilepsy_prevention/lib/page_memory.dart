import 'package:epilepsy_prevention/notifications.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';
import 'package:epilepsy_prevention/memory.dart';

class PageMemory extends StatelessWidget
{
  PageMemory(this.m_memory);

  final Memory m_memory;

  bool m_bChangeNotifyTimes = false;

  final m_questionTextController = TextEditingController();
  final m_answerTextController = TextEditingController();
  final m_wrongAnswersTextController = TextEditingController();

  Widget build(BuildContext context)
  {
    m_questionTextController.text = m_memory.m_question;
    m_answerTextController.text = m_memory.m_answer;
    m_wrongAnswersTextController.text = m_memory.m_falseAnswers;

    return Scaffold(body: StatefulBuilder(builder: (BuildContext context, StateSetter setState){
      return Column(children: <Widget>[

        const Spacer(),

        const Text("Question", style: TextStyle(fontSize: 30),
            textAlign: TextAlign.left),

        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter a search question',
          ),
          style: const TextStyle(fontSize: 30.0, color: Colors.black),
          controller: m_questionTextController,
        ),

        const Spacer(),

        const Text("Correct Answer",
            style: TextStyle(fontSize: 30, color: Colors.black),
            textAlign: TextAlign.left),

        TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter a answer',
            ),
            controller: m_answerTextController
        ),

        const Spacer(),

        const Text("Multi Choice: ", style: TextStyle(fontSize: 30, color: Colors.black), textAlign: TextAlign.center),

        Checkbox(value: m_memory.m_bMultiChoice, onChanged: (bool? value) {
          if (value != null) {
            setState(() {
              m_memory.m_bMultiChoice = value;
            });
          }
        }),

        const Spacer(),

        Visibility(visible: m_memory.m_bMultiChoice, child:
        TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(),
                hintText: 'Enter wrong answers.'),
            style: const TextStyle(fontSize: 30, color: Colors.black),
            controller: m_wrongAnswersTextController
        )
        ),

        const Spacer(),

        const Text("Reminder frequency", style: TextStyle(fontSize: 30), textAlign: TextAlign.left),

        DropdownButton(
          items: const [
            DropdownMenuItem(
                value: "Never", child: Text("Never", style: TextStyle(
                fontSize: 25, color: Colors.black), textAlign: TextAlign
                .center)),
            DropdownMenuItem(
                value: "Rare", child: Text("Rare", style: TextStyle(
                fontSize: 25, color: Colors.black), textAlign: TextAlign
                .center)),
            DropdownMenuItem(value: "Occasionally",
                child: Text("Occasionally", style: TextStyle(
                    fontSize: 25, color: Colors.black), textAlign: TextAlign
                    .center)),
            DropdownMenuItem(value: "Frequently",
                child: Text("Frequently", style: TextStyle(
                    fontSize: 25, color: Colors.black), textAlign: TextAlign
                    .center))
          ],
          value: m_memory.m_testFrequecy,
          onChanged: (String? selectedValue) {
            setState(() {
              if (selectedValue != null) {
                m_memory.m_testFrequecy = selectedValue;
                m_bChangeNotifyTimes = true;
              }
            });
          }
        ),

        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[

              TextButton(onPressed: () {
                var box = Database().getMemoryBox();
                if (box != null) {

                  //Clear notifications
                  for (int notifyTime in m_memory.m_notifyTimes) {
                    Notifications().removeNotification(
                        m_memory.key.toString() + "-" + notifyTime.toString());
                  }

                  box.delete(m_memory.key);
                }

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PageHome()));
              },
                  child: const Text("Delete",
                      style: TextStyle(fontSize: 30, color: Colors.black))),

              TextButton(onPressed: () async {
                Database db = Database();
                var box = db.getMemoryBox();
                if (box != null) {
                  m_memory.m_question = m_questionTextController.text;
                  m_memory.m_answer = m_answerTextController.text;
                  m_memory.m_falseAnswers = m_wrongAnswersTextController.text;

                  if (m_bChangeNotifyTimes) {
                    List<int> notifyTimes = <int>[];

                    Notifications notifications = Notifications();

                    //Clear previous notifications
                    for (int notifyTime in m_memory.m_notifyTimes) {
                      notifications.removeNotification(
                          m_memory.key.toString() + "-" + notifyTime.toString());
                    }

                    if (m_memory.m_testFrequecy == "Rare") {
                      int notifyTime = 60;
                      notifyTimes.add(notifyTime);
                    }
                    else if (m_memory.m_testFrequecy == "Occasionally") {
                      int notifyTime = 30;
                      notifyTimes.add(notifyTime);
                    }
                    else if (m_memory.m_testFrequecy == "Frequently") {
                      int notifyTime = 1;
                      notifyTimes.add(notifyTime);
                    }

                    m_memory.m_notifyTimes = notifyTimes;
                  }

                  var key;
                  if(db.getMemoryWithId(m_memory.key) == null)
                  {
                    key = await box.add(m_memory);
                  }
                  else
                  {
                    box.put(m_memory.key, m_memory);
                    key = m_memory.key;
                  }

                  for(int notifyTime in m_memory.m_notifyTimes)
                  {
                    await Notifications().scheduleNotification(key, m_memory, notifyTime, key.toString() + "-" + notifyTime.toString());
                  }
                }

                Navigator.push(context, MaterialPageRoute(builder: (context) => const PageHome()));
              },
                  child: const Text("Save", style: TextStyle(fontSize: 30, color: Colors.black)))
            ]),

        const Spacer()
      ]);
  }));
  }
}