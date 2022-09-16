import 'package:flutter/material.dart';

class PageNewEntry extends StatelessWidget
{
  PageNewEntry({super.key});

  bool? m_bMultiChoice = false;

  Widget build(BuildContext context)
  {
    return Scaffold(
        body: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[

          Column(children: const [
            Text("Question", style: TextStyle(fontSize: 10), textAlign: TextAlign.left),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a search question',
              ),
            )
          ],),

          const Spacer(),

          Column(children: const [
            Text("Correct Answer", style: TextStyle(fontSize: 10), textAlign: TextAlign.left),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter a answer',
              ),
            )
          ]),

          const Spacer(),

          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            const Text("Multi Choice: ", style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
            Checkbox(value: m_bMultiChoice, onChanged: (bool? value){m_bMultiChoice = value;})
          ]
          ),

          const Visibility(visible: true,
              child:  TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter wrong answers.',
            ),
          ))
        ]
        ),
    );
  }
}