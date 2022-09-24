import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/page_memoryReminders.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';

class PageMemory extends StatelessWidget
{
  PageMemory(this.m_memory);

  Memory m_memory;
  List<int> m_oldNotifyTimes = [];

  bool m_bChangeNotifyTimes = false;

  final m_questionTextController = TextEditingController();
  final m_answerTextController = TextEditingController();
  final m_wrongAnswersTextController = TextEditingController();

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

    m_oldNotifyTimes = m_memory.m_notifyTimes;

    m_questionTextController.text = m_memory.m_question;
    m_answerTextController.text = m_memory.m_answer;

    for(String falseAnswer in m_memory.m_falseAnswers)
    {
      m_wrongAnswersTextController.text += falseAnswer + ",";
    }

    return Scaffold(body: StatefulBuilder(builder: (BuildContext context, StateSetter setState){
      return Column(children: <Widget>[

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: const Text("Question", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

        IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: TextField(maxLines: null,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a search question'),
          style: const TextStyle(fontSize: 30.0, color: Colors.black),
          controller: m_questionTextController,
        ))),

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: const Text("Correct Answer", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

        IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: TextField(maxLines: null,
          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a answer'),
          style: const TextStyle(fontSize: 30.0, color: Colors.black),
          controller: m_answerTextController,
        ))),

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: Row(children: [
          const Text("Multiple Choice: ", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left),
          Checkbox(value: m_memory.m_bMultiChoice, onChanged: (bool? value) {
            if (value != null) {
              setState(() {
                m_memory.m_bMultiChoice = value;
              });
            }
          }),
        ])),

      IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Visibility(visible: m_memory.m_bMultiChoice, child:
        TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter wrong answers.'),
            style: const TextStyle(fontSize: 30, color: Colors.black),
            controller: m_wrongAnswersTextController
        )
      ))),

        const Spacer(),

        SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 70, child: Row(children : [
          const Text("Reminders: ", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left),
          TextButton(onPressed: () async {
            m_memory = await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemoryReminders(m_memory: m_memory)));
            m_bChangeNotifyTimes = true;
          }, child: const Text("⚙", style: TextStyle(fontSize: 30, color: Colors.black), textAlign: TextAlign.left))
        ])),

        const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () => onDelete(context), child: const Text("Delete", style: TextStyle(fontSize: 30, color: Colors.blue))),

          const Spacer(),

          TextButton(onPressed: () => onSave(context), child: const Text("Save", style: TextStyle(fontSize: 30, color: Colors.blue))),

          const Spacer()
        ]),

        const Spacer()
      ]);
  }));
  }

  void onSave(BuildContext context) async
  {
    m_memory.m_question = m_questionTextController.text;
    m_memory.m_answer = m_answerTextController.text;
    m_memory.m_falseAnswers = m_wrongAnswersTextController.text.split(",");

    final String validationResult = m_memory.validate();
    if(validationResult != "Success")
    {
      showDialog(context: context, builder: (context){return AlertDialog(title: const Text("Adding Memory Failed!"), content: Text(validationResult));});
      return;
    }

    Database db = Database();
    var box = db.getMemoryBox();
    if (box != null)
    {
      if (m_bChangeNotifyTimes)
      {
        //Clear previous notifications
        if(m_memory.key != null)
        {
          Notifications().removeNotifications(m_memory.key, m_oldNotifyTimes);
        }
      }

      var key;
      if(db.getMemoryWithId(m_memory.key) == null)
      {
        key = await box.add(m_memory);
      }
      else
      {
        key = db.updateMemory(m_memory);
      }

      await Notifications().scheduleNotifications(key, m_memory.m_question, m_memory.m_notifyTimes);
    }

    Navigator.of(context).pop();
  }

  void onDelete(BuildContext context)
  {
    var box = Database().getMemoryBox();
    if (box != null && m_memory.key != null)
    {
      //Clear notifications
      Notifications().removeNotifications(m_memory.key, m_memory.m_notifyTimes);

      //Delete
      box.delete(m_memory.key);
    }

    Navigator.of(context).pop();
  }
}