import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:epilepsy_prevention/notifications.dart';

class MemoryNotification
{
  MemoryNotification(int notifyTime, bool bHasBeenTested)
  {
    m_notifyTime = notifyTime;
    m_bHasBeenTested = bHasBeenTested;//notifyTime < DateTime.now().millisecondsSinceEpoch;
  }

    int m_notifyTime = 0;
    bool m_bHasBeenTested = false;
}

@HiveType(typeId: 0)
class Memory extends HiveObject
{
  Memory({String question = "", String answer = "", bool multiChoice = false, List<String> falseAnswers = const [], String testFrequency = "Never", List<MemoryNotification> notifyTimes = const [], bool enabledNotifications = true})
  {
    m_question = question;
    m_answer = answer;
    m_bMultiChoice = multiChoice;
    m_falseAnswers = falseAnswers;
    m_testFrequecy = testFrequency;
    m_bNotificationsEnabled = enabledNotifications;
    m_notifyTimes = notifyTimes;
  }

  @HiveField(0)
  String m_question = "";

  @HiveField(1)
  String m_answer = "";

  @HiveField(2)
  List<String> m_falseAnswers = [];

  @HiveField(3)
  bool m_bMultiChoice = false;

  @HiveField(4)
  String m_testFrequecy = "Never";

  @HiveField(5)
  List<MemoryNotification> m_notifyTimes = <MemoryNotification>[];

  @HiveField(6)
  bool m_bNotificationsEnabled = true;

  String validate()
  {
    if(m_question == "")
    {
      return "Invalid question format";
    }

    if(m_question[m_question.length-1] != "?")
    {
        m_question += " ?";
    }

    if(m_answer == "")
    {
      return "Invalid answer format";
    }

    if(m_bMultiChoice)
    {
      if(m_falseAnswers.isEmpty)
      {
        return "Must have at least one false answer";
      }

      for(String falseAnswer in m_falseAnswers)
      {
        if(falseAnswer == "")
        {
          return "Can't have blank false answer";
        }
      }
    }

    if(m_testFrequecy == "")
    {
        return "Invalid test frequency";
    }

    return "Success";
  }

  void setNewNotifyTimes(List<int> notifyTimes)
  {
    m_notifyTimes.clear();

    for(int notifyTime in notifyTimes)
    {
      m_notifyTimes.add(MemoryNotification(notifyTime, notifyTime < DateTime.now().millisecondsSinceEpoch));
    }
  }
}

class MemoryAdapter extends TypeAdapter<Memory>
{
  @override
  final typeId = 0;

  @override
  Memory read(BinaryReader reader)
  {
    try
    {
      String question = reader.readString();
      String answer = reader.readString();
      bool multiChoice = reader.readBool();
      List<String> falseAnswers = reader.readStringList();
      String testFrequency = reader.readString();
      bool enabledNotifications = reader.readBool();

      List<int> notifyTimes = reader.readIntList();
      List<bool> isNotificationTestedList = reader.readBoolList();
      List<MemoryNotification> memoryNotifications = <MemoryNotification>[];
      if(notifyTimes.length == isNotificationTestedList.length)
      {
        for(int i = 0; i < notifyTimes.length; i++)
        {
          memoryNotifications.add(MemoryNotification(notifyTimes[i], isNotificationTestedList[i]));
        }
      }

      return Memory(question: question, answer: answer, multiChoice: multiChoice, falseAnswers: falseAnswers, testFrequency: testFrequency, notifyTimes: memoryNotifications, enabledNotifications: enabledNotifications);
    }
    catch (e)
    {
      return Memory();
    }
  }

  @override
  void write(BinaryWriter writer, Memory obj)
  {
    writer.writeString(obj.m_question);
    writer.writeString(obj.m_answer);
    writer.writeBool(obj.m_bMultiChoice);
    writer.writeStringList(obj.m_falseAnswers);
    writer.writeString(obj.m_testFrequecy);
    writer.writeBool(obj.m_bNotificationsEnabled);

    List<int> notifyTimes = [];
    List<bool> isNotificationTestedList = [];
    for(MemoryNotification memoryNotification in obj.m_notifyTimes)
    {
      notifyTimes.add(memoryNotification.m_notifyTime);
      isNotificationTestedList.add(memoryNotification.m_bHasBeenTested);
    }
    writer.writeIntList(notifyTimes);
    writer.writeBoolList(isNotificationTestedList);
  }
}

class Database
{
  static final Database _m_database = Database._internal();
  static Box<Memory>? _m_memoryBox;
  static Box? _m_settingsBox;

  factory Database()
  {
    return _m_database;
  }

  Database._internal();

  Future<void> init()
  async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Hive.registerAdapter(MemoryAdapter());

    _m_memoryBox = await Hive.openBox("Memories.db");
    _m_settingsBox = await Hive.openBox("settings.db");
  }

  int getAndIncrementChannelNumber()
  {
    int result = int.parse(_m_settingsBox?.get("channel number") ?? "267");
    result++;

    if(result >= 922337203685477580)
    {
      result = 0;
    }

    _m_settingsBox?.put("channel number", result.toString());
    return result;
  }

  bool getNotificationsEnabledSetting()
  {
    return _m_settingsBox?.get("notifications enabled") != "false";
  }

  void setNotificationsEnabledSetting(bool enabled)
  {
    _m_settingsBox?.put("notifications enabled", enabled ? "true" : "false");
  }

  Box<Memory>? getMemoryBox()
  {
    return _m_memoryBox;
  }

  Future<int> addOrUpdateMemory(Memory memory) async
  {
    if(_m_memoryBox != null)
    {
      if(getMemoryWithId(memory.key) != null)
      {
        _m_memoryBox?.put(memory.key, memory);
        return memory.key;
      }
      else
      {
        return (await _m_memoryBox?.add(memory)) ?? memory.key;
      }
    }
    return memory.key;
  }

  void deleteMemory(dynamic memoryKey)
  {
    if(_m_memoryBox != null)
    {
        _m_memoryBox?.delete(memoryKey);
    }
  }

  void deleteAllMemories()
  {
    var memoryBox = Database().getMemoryBox();
    if(memoryBox != null)
    {
      for(Memory memory in memoryBox.values)
      {
        Notifications().removeNotifications(memory.key, memory.m_notifyTimes);
        memoryBox.delete(memory.key);
      }
    }
  }

  void deleteAllNotifyTimes()
  {
    var memoryBox = Database().getMemoryBox();
    if(memoryBox != null)
    {
      for(Memory memory in memoryBox.values)
      {
        Notifications().removeNotifications(memory.key, memory.m_notifyTimes);
        memory.m_notifyTimes = [];
        memoryBox.put(memory.key, memory);
      }
    }
  }

  Memory? getMemoryWithId(dynamic key)
  {
    var box = Database().getMemoryBox();
    if(box != null)
    {
      for(Memory memory in box.values)
      {
        if(memory.key == key)
        {
          return memory;
        }
      }
    }
    return null;
  }

  void generateTestData() async
  {
    Memory mem1 = Memory(question: "Question1", answer: "Answer1", multiChoice: false, falseAnswers: [], testFrequency: "Never", notifyTimes: [], enabledNotifications: true);
    Memory mem2 = Memory(question: "question2", answer: "answer2", multiChoice: false, falseAnswers: [], testFrequency: "Frequently", notifyTimes: Notifications().genNotifyTimes(0, 5, 2, 900000), enabledNotifications: true);
    Memory mem3 = Memory(question: "Question3", answer: "Answer3", multiChoice: false, falseAnswers: [], testFrequency: "Frequently", notifyTimes: Notifications().genNotifyTimes(0, 5, 2, 900000), enabledNotifications: false);
    Memory mem4 = Memory(question: "Question4", answer: "Answer4", multiChoice: false, falseAnswers: [], testFrequency: "Occasionally", notifyTimes: Notifications().genNotifyTimes(0, 5, 3, 1200000), enabledNotifications: true);
    Memory mem5 = Memory(question: "Question5", answer: "Answer5", multiChoice: true, falseAnswers: ["Apples", "Pears", "Oranges", "Pinapples", "Lemons"], testFrequency: "Never", notifyTimes: [], enabledNotifications: true);
    Memory mem6 = Memory(question: "question6", answer: "answer6", multiChoice: true, falseAnswers: ["Apples", "Pears", "Oranges", "Pinapples", "Lemons"], testFrequency: "Frequently", notifyTimes: Notifications().genNotifyTimes(0, 5, 2, 900000), enabledNotifications: true);
    Memory mem7 = Memory(question: "Question7", answer: "Answer7", multiChoice: true, falseAnswers: ["Apples", "Pears", "Oranges", "Pinapples", "Lemons"], testFrequency: "Frequently", notifyTimes: Notifications().genNotifyTimes(0, 5, 2, 900000), enabledNotifications: false);
    Memory mem8 = Memory(question: "Question8", answer: "Answer8", multiChoice: true, falseAnswers: ["Apples"], testFrequency: "Occasionally", notifyTimes: Notifications().genNotifyTimes(0, 5, 3, 1200000), enabledNotifications: true);

    var box = Database().getMemoryBox();
    if(box != null)
    {
      var notifications = Notifications();

      var key = await box.add(mem1);
      notifications.scheduleNotifications(key, mem1.m_question, mem1.m_notifyTimes);

      key = await box.add(mem2);
      notifications.scheduleNotifications(key, mem2.m_question, mem2.m_notifyTimes);

      await box.add(mem3);

      key = await box.add(mem4);
      notifications.scheduleNotifications(key, mem4.m_question, mem4.m_notifyTimes);

      key = await box.add(mem5);
      notifications.scheduleNotifications(key, mem5.m_question, mem5.m_notifyTimes);

      key = await box.add(mem6);
      notifications.scheduleNotifications(key, mem6.m_question, mem6.m_notifyTimes);

      await box.add(mem7);

      key = await box.add(mem8);
      notifications.scheduleNotifications(key, mem8.m_question, mem8.m_notifyTimes);
    }
  }
}
