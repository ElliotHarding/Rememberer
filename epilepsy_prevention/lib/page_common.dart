import 'package:epilepsy_prevention/notifications.dart';
import 'package:epilepsy_prevention/memory.dart';
import 'package:epilepsy_prevention/page_test.dart';
import 'package:flutter/material.dart';

class BasePage
{
  static var m_currentContext;

  static void initNotificationActionListener()
  {
    Notifications.m_selectedNotificationSubject.stream.listen((String? memoryKey) async {
      if(memoryKey != null) {
        var database = Database();
        int? keyValue = int.tryParse(memoryKey);
        if(keyValue != null)
        {
          Memory? mem = database.getMemoryWithId(keyValue);
          if (mem != null)
          {
            if(m_currentContext != null)
            {
                Notifications.m_selectedNotificationSubject.add(null);
                Navigator.push(m_currentContext, MaterialPageRoute(builder: (context) => PageTest(mem)));
            }
          }
        }
      }
    });
  }

  static void setupNotificationActionListener(BuildContext context)
  {
    m_currentContext = context;
  }
}