import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/page_memoryReminders.dart';
import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/display.dart';

class PageMemory extends StatefulWidget
{
  PageMemory(this.m_memory, {Key? key}) : super(key: key);

  Memory m_memory;

  @override
  State<PageMemory> createState() => PageMemoryState();
}

class PageMemoryState extends State<PageMemory>
{
  Memory m_oldMemory = Memory();
  bool m_bChangeNotifyTimes = false;

  List<TextEditingController> m_falseAnswerTextEditControllers = [];
  final m_questionTextController = TextEditingController();
  final m_answerTextController = TextEditingController();

  void initState()
  {
    initialFalseAnswerList();

    m_oldMemory = widget.m_memory;

    m_questionTextController.text = widget.m_memory.m_question;
    m_answerTextController.text = widget.m_memory.m_answer;
  }

  Widget build(BuildContext context)
  {
    Notifications.setupNotificationActionListener(context);

    final double headerLeftMargin = MediaQuery.of(context).size.width * 0.05;
    final double verticalSpacer = MediaQuery.of(context).size.height * 0.05;

    return Scaffold(body: SizedBox(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height, child:
      ListView(shrinkWrap: true, children: <Widget>[

        Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin, verticalSpacer, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
          Text("Question:", style: Display.largeTextStyle, textAlign: TextAlign.left),
        )),

        Center(child: IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          TextField(maxLines: null, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a search question'), style: Display.largeTextStyleBlack, controller: m_questionTextController)
        ))),

        Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin, verticalSpacer, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
          Text("Correct Answer:", style: Display.largeTextStyle, textAlign: TextAlign.left),
        )),

        Center(child: IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          TextField(maxLines: null,
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter a answer'),
            style: Display.largeTextStyleBlack,
            controller: m_answerTextController,
        )))),

        Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin, verticalSpacer, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
          Text("Multiple Choice:", style: Display.largeTextStyle, textAlign: TextAlign.left),
        )),

        Row(children: [
          Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin * 2, 0, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Enable:", style: Display.normalTextStyle, textAlign: TextAlign.left),
          )),
          Checkbox(value: widget.m_memory.m_bMultiChoice, onChanged: (bool? value) => setMultiChoice(value))
        ]),

        Visibility(visible: widget.m_memory.m_bMultiChoice, child:
          Row(children: [
            Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin * 2, 0, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
              Text("Add:", style: Display.normalTextStyle, textAlign: TextAlign.left),
            )),
            TextButton(onPressed: addFalseAnswer, child: Text("+", style: Display.largeTextStyle, textAlign: TextAlign.center))
        ])),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child: Visibility(visible: widget.m_memory.m_bMultiChoice, child:
          ListView.builder(itemCount: m_falseAnswerTextEditControllers.length, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, scrollDirection: Axis.vertical, itemBuilder: (context, i){ return genFalseAnswerWidget(context, i);}))
        )),

        Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin, verticalSpacer, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
          Text("Reminders:", style: Display.largeTextStyle, textAlign: TextAlign.left),
        )),

        Row(children: [
          Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin * 2, 0, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Enable:", style: Display.normalTextStyle, textAlign: TextAlign.left),
          )),
          Checkbox(value: widget.m_memory.m_bNotificationsEnabled, onChanged: (bool? value) => onEnableNotificationsChanged(value))
        ]),

        Row(children: [
          Padding(padding: EdgeInsets.fromLTRB(headerLeftMargin * 2, 0, 0, 0), child: Align(alignment: Alignment.centerLeft, child:
            Text("Configure:", style: Display.normalTextStyle, textAlign: TextAlign.left),
          )),
          TextButton(onPressed: () => onPressReminders(context), child:
            Text("⚙", style: Display.largeTextStyle, textAlign: TextAlign.left)
          )
        ]),

        SizedBox(height: verticalSpacer),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () => onDelete(context), child: Text("Delete", style: Display.miniNavButtonTextStyle)),

          const Spacer(),

          TextButton(onPressed: () => onCancel(context), child: Text("|Cancel|", style: Display.miniNavButtonTextStyle)),

          const Spacer(),

          TextButton(onPressed: () => onSave(context), child: Text("Save", style: Display.miniNavButtonTextStyle)),

          const Spacer()
        ]),

        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        //const Spacer()
      ])
    ));
  }

  bool getMemorySettingsAndValidate(BuildContext context)
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
      return false;
    }
    return true;
  }

  void onSave(BuildContext context) async
  {
    if(!getMemorySettingsAndValidate(context))
    {
      return;
    }

    Database db = Database();

    //If not new memory, and updated notify times, and notifcations are enabled: clear old scheduled notifications
    if(widget.m_memory.key != null && db.getNotificationsEnabledSetting() && m_bChangeNotifyTimes)
    {
      await Notifications().removeNotifications(widget.m_memory.key, m_oldMemory.getNotifyTimes());
    }

    //Add or update memory to database and schedule its notifcations
    var key = await db.addOrUpdateMemory(widget.m_memory);
    if(db.getNotificationsEnabledSetting() && widget.m_memory.m_bNotificationsEnabled)
    {
      await Notifications().scheduleNotifications(key, widget.m_memory.m_question, widget.m_memory.getNotifyTimes());
    }

    Navigator.of(context).pop();
  }

  void onDelete(BuildContext context)
  {
    if (widget.m_memory.key != null)
    {
      //Clear notifications
      Notifications().removeNotifications(widget.m_memory.key, widget.m_memory.getNotifyTimes());

      Database().deleteMemory(widget.m_memory.key);
    }

    Navigator.of(context).pop();
  }

  void onCancel(BuildContext context)
  {
    Navigator.of(context).pop();
  }

  void onPressReminders(BuildContext context) async
  {
    widget.m_memory = await Navigator.push(context, MaterialPageRoute(builder: (context) => PageMemoryReminders(m_memory: widget.m_memory)));
    m_bChangeNotifyTimes = true;
  }

  void setMultiChoice(bool? value)
  {
    if (value != null)
    {
      setState(()
      {
        widget.m_memory.m_bMultiChoice = value;
      });
    }
  }

  void onEnableNotificationsChanged(bool? value)
  {
    if(value != null)
    {
      setState(()
      {
        widget.m_memory.m_bNotificationsEnabled = value;
        m_bChangeNotifyTimes = true;
      });
    }
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
        SizedBox(width: MediaQuery.of(context).size.width * 0.76, child:
          TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter wrong answer.'),
            style: Display.listItemTextStyleBlack,
            controller: m_falseAnswerTextEditControllers[iFalseAnswer],
            maxLines: null,
          )
        ),
        SizedBox(width: MediaQuery.of(context).size.width * 0.14, child:
          TextButton(onPressed: () { setState(() {
            m_falseAnswerTextEditControllers.removeAt(iFalseAnswer);
          });}, child: Text("X", style: Display.listItemTextStyle)),
        )
      ])
    ));
  }
}