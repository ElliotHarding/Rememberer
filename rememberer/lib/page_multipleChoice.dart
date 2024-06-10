import 'notifications.dart';
import 'package:flutter/material.dart';
import 'display.dart';

class PageMultipleChoices extends StatefulWidget
{
  PageMultipleChoices({required this.m_previousMultiChoices, Key? key}) : super(key: key);

  List<String> m_previousMultiChoices = [];

  @override
  State<PageMultipleChoices> createState() => PageMultipleChoicesState();
}

class PageMultipleChoicesState extends State<PageMultipleChoices> {
  List<TextEditingController> m_multiChoiceTextEditControllers = [];

  void initState() {
    setState(() {
      for (String falseAnswer in widget.m_previousMultiChoices) {
        TextEditingController txtEditController = TextEditingController();
        txtEditController.text = falseAnswer;
        m_multiChoiceTextEditControllers.add(txtEditController);
      }
    });
  }

  Widget build(BuildContext context) {
    Notifications.setupNotificationActionListener(context);

    final double verticalSpacer = MediaQuery.of(context).size.height * 0.05;

    return WillPopScope(onWillPop: () async {onUpdate(); return true;}, child:
      Scaffold(body: ListView(shrinkWrap: true, children: <Widget>[

        SizedBox(height: verticalSpacer),

        Row(children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
          SizedBox(width: MediaQuery.of(context).size.width * 0.6 , child: Text("Multiple Choices:", style: Display.largeTextStyle, textAlign: TextAlign.left)),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2, child: TextButton(onPressed: addFalseAnswer, child: Text("📝⁺", style: Display.largeTextStyle, textAlign: TextAlign.center)))
        ],),

        SizedBox(height: verticalSpacer),

        Center(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
          ListView.builder(itemCount: m_multiChoiceTextEditControllers.length, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, scrollDirection: Axis.vertical, itemBuilder: (context, i){ return genFalseAnswerWidget(context, i);}))
        ),

        SizedBox(height: verticalSpacer),

        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
          const Spacer(),

          TextButton(onPressed: () => onCancel(), child: Text("Cancel", style: Display.miniNavButtonTextStyle)),

          const Spacer(),

          TextButton(onPressed: () => onUpdate(), child: Text("Update", style: Display.miniNavButtonTextStyle)),

          const Spacer()
        ]),

        SizedBox(height: verticalSpacer)
    ])
    ));
  }

  Widget genFalseAnswerWidget(BuildContext context, int iFalseAnswer)
  {
    return IntrinsicHeight(child: SizedBox(width: MediaQuery.of(context).size.width * 0.9, child:
    Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
      SizedBox(width: MediaQuery.of(context).size.width * 0.76, child:
      TextField(
        decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter wrong answer.'),
        style: Display.listItemTextStyleBlack,
        controller: m_multiChoiceTextEditControllers[iFalseAnswer],
        maxLines: null,
      )
      ),
      SizedBox(width: MediaQuery.of(context).size.width * 0.14, child:
      TextButton(onPressed: () { setState(() {
        m_multiChoiceTextEditControllers.removeAt(iFalseAnswer);
      });}, child: Text("🗑", style: Display.listItemTextStyle)),
      )
    ])
    ));
  }

  void addFalseAnswer()
  {
    setState(() {
      m_multiChoiceTextEditControllers.add(TextEditingController());
    });
  }

  void onCancel()
  {
    Navigator.pop(context, widget.m_previousMultiChoices);
  }

  void onUpdate()
  {
    List<String> falseAnswers = [];
    for(TextEditingController txtCtrllr in m_multiChoiceTextEditControllers)
    {
      falseAnswers.add(txtCtrllr.text);
    }
    Navigator.pop(context, falseAnswers);
  }
}