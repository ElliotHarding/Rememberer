import 'package:flutter/material.dart';
import 'package:epilepsy_prevention/page_home.dart';

class PageNewEntry extends StatelessWidget
{
  PageNewEntry({super.key});

  bool m_bMultiChoice = false;

  Widget build(BuildContext context)
  {
    return Scaffold(
        body: Column(children: <Widget>[

          const Spacer(),

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

          Visibility(visible: m_bMultiChoice,
              child:  const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter wrong answers.',
            ),
          )),

          const Spacer(),

          Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageHome()));
            }, child: const Text("Cancel")),
            TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PageHome()));
            }, child: const Text("Add"))
          ]),

          const Spacer()
        ]
        ),
    );
  }
}