import 'package:flutter/material.dart';

class PageHome extends StatefulWidget
{
  const PageHome({Key? key}) : super(key: key);

  @override
  State<PageHome> createState() => PageHomeState();
}

class PageHomeState extends State<PageHome>
{
  bool? m_bAppEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: <Widget>[
            const Text("Enable: ", style: TextStyle(fontSize: 10)),
            Checkbox(value: m_bAppEnabled,
                onChanged: (bool? value){
                  setState((){
                    m_bAppEnabled = value;
                  });})
          ]
          )
    );
  }
}