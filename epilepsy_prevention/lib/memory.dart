import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Memory extends HiveObject
{
  Memory({String question = "", String answer = "", bool multiChoice = false, List<String> falseAnswers = const [], String testFrequency = "Never", List<int> notifyTimes = const []})
  {
    m_question = question;
    m_answer = answer;
    m_bMultiChoice = multiChoice;
    m_falseAnswers = falseAnswers;
    m_testFrequecy = testFrequency;
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
  List<int> m_notifyTimes = <int>[];

  String validate()
  {
    if(m_question == "")
    {
      return "Invalid question format";
    }

    if(m_answer == "")
    {
      return "Invalid answer format";
    }

    if(m_bMultiChoice && m_falseAnswers.isEmpty)
    {
        return "Must have at least one false answer";
    }

    if(m_testFrequecy == "")
    {
        return "Invalid test frequency";
    }

    return "Success";
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
      List<int> notifyTimes = reader.readIntList();
      return Memory(question: question, answer: answer, multiChoice: multiChoice, falseAnswers: falseAnswers, testFrequency: testFrequency, notifyTimes: notifyTimes);
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
    writer.writeIntList(obj.m_notifyTimes);
  }
}

class Database
{
  static final Database m_database = Database._internal();
  static Box<Memory>? m_memoryBox;
  static Box? _m_settingsBox;

  factory Database()
  {
    return m_database;
  }

  Database._internal();

  Future<void> init()
  async {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
    Hive.registerAdapter(MemoryAdapter());

    m_memoryBox = await Hive.openBox("Memories.db");
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
    return m_memoryBox;
  }

  int updateMemory(Memory memory)
  {
    if(m_memoryBox != null)
    {
        m_memoryBox?.put(memory.key, memory);
    }
    return memory.key;
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
}
