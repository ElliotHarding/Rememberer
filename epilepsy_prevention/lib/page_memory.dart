import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/page_memoryReminders.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';

class PageMemory extends StatefulWidget
{
  PageMemory(this.m_memory, {Key? key}) : super(key: key);

  Memory m_memory;

  @override
  State<PageMemory> createState() => PageMemoryState();
}

class PageMemoryState extends State<PageMemory>
{
  List<int> m_oldNotifyTimes = [];
  bool m_bChangeNotifyTimes = false;

  List<TextEditingController> m_falseAnswerTextEditControllers = [];
  final m_questionTextController = TextEditingController();
  final m_answerTextController = TextEditingController();

  void initState()
  {
    initialFalseAnswerList();

    m_oldNotifyTimes = widget.m_memory.m_notifyTimes;

    m_questionTextController.text = widget.m_memory.m_question;
    m_answerTextController.text = widget.m_memory.m_answer;
  }

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    return Scaffold(body: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child:
      ListView(shrinkWrap: true, children: <Widget>[

        //const Spacer(),

        Center(child: Column(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: const Text("Question", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),
          IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: TextField(maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a search question'),
            style: const TextStyle(fontSize: 30.0, color: Colors.black),
            controller: m_questionTextController,
          )))
          ])
        ),

        //const Spacer(),

        Center(child: Column(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 35, child: const Text("Correct Answer", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left)),

          IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: TextField(maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a answer'),
            style: const TextStyle(fontSize: 30.0, color: Colors.black),
            controller: m_answerTextController,
          ))),
        ])),

        //const Spacer(),

        Center(child: Column(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 70, child: Row(children: [

            const Text("Multiple Choice: ", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left),

            Checkbox(value: widget.m_memory.m_bMultiChoice, onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  widget.m_memory.m_bMultiChoice = value;
                });
              }
            }),

            const Spacer(),

            Visibility(visible: widget.m_memory.m_bMultiChoice, child:
            TextButton(onPressed: addFalseAnswer, child: const Text("+", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.center))
            )
          ])),

          SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Visibility(visible: widget.m_memory.m_bMultiChoice, child:
            ListView.builder(itemCount: m_falseAnswerTextEditControllers.length, shrinkWrap: true, scrollDirection: Axis.vertical, itemBuilder: (context, i){ return genFalseAnswerWidget(context, i);}))
          )
        ])),
        //const Spacer(), 

        Center(child:SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: 70, child: Row(children : [
          const Text("Reminders: ", style: TextStyle(fontSize: 30, color: Colors.blue), textAlign: TextAlign.left),
          TextButton(onPressed: () async {
            widget.m_memory = await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemoryReminders(m_memory: widget.m_memory)));
            m_bChangeNotifyTimes = true;
          }, child: const Text("⚙", style: TextStyle(fontSize: 30, color: Colors.black), textAlign: TextAlign.left))
        ]))),

        //const Spacer(),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () => onDelete(context), child: const Text("Delete", style: TextStyle(fontSize: 30, color: Colors.blue))),

          const Spacer(),

          TextButton(onPressed: () => onSave(context), child: const Text("Save", style: TextStyle(fontSize: 30, color: Colors.blue))),

          const Spacer()
        ]),

        //const Spacer()
      ])
    ));
  }

  void onSave(BuildContext context) async
  {
    widget.m_memory.m_question = m_questionTextController.text;
    widget.m_memory.m_answer = m_answerTextController.text;

    List<String> falseAnswers = [];
    for(TextEditingController txtCtrllr in m_falseAnswerTextEditControllers)
    {
      falseAnswers.add(txtCtrllr.text);
    }
    widget.m_memory.m_falseAnswers = falseAnswers;

    final String validationResult = widget.m_memory.validate();
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
        if(widget.m_memory.key != null)
        {
          Notifications().removeNotifications(widget.m_memory.key, m_oldNotifyTimes);
        }
      }

      var key;
      if(db.getMemoryWithId(widget.m_memory.key) == null)
      {
        key = await box.add(widget.m_memory);
      }
      else
      {
        key = db.updateMemory(widget.m_memory);
      }

      await Notifications().scheduleNotifications(key, widget.m_memory.m_question, widget.m_memory.m_notifyTimes);
    }

    Navigator.of(context).pop();
  }

  void onDelete(BuildContext context)
  {
    var box = Database().getMemoryBox();
    if (box != null && widget.m_memory.key != null)
    {
      //Clear notifications
      Notifications().removeNotifications(widget.m_memory.key, widget.m_memory.m_notifyTimes);

      //Delete
      box.delete(widget.m_memory.key);
    }

    Navigator.of(context).pop();
  }

  void initialFalseAnswerList()
  {
    for(String falseAnswer in widget.m_memory.m_falseAnswers)
    {
      TextEditingController txtEditController = TextEditingController();
      txtEditController.text = falseAnswer;
      m_falseAnswerTextEditControllers.add(txtEditController);
    }
  }

  void addFalseAnswer()
  {
    setState(() {
      m_falseAnswerTextEditControllers.add(TextEditingController());
    });
  }

  Widget genFalseAnswerWidget(BuildContext context, int iFalseAnswer)
  {
    return IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
      Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
        SizedBox(width: MediaQuery.of(context).size.width * 0.7, child:
          TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter wrong answer.'),
            style: const TextStyle(fontSize: 30, color: Colors.black),
            controller: m_falseAnswerTextEditControllers[iFalseAnswer],
            maxLines: null,
          )
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.2, child:
          TextButton(onPressed: () { setState(() {
            m_falseAnswerTextEditControllers.removeAt(iFalseAnswer);
          });}, child: const Text("X", style: TextStyle(fontSize: 30, color: Colors.black))),
        )
      ])
    ));
  }
}