import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Memory extends HiveObject
{
  Memory({String question = "", String answer = "", bool multiChoice = false, String falseAnswers = "", String testFrequency = ""})
  {
    m_question = question;
    m_answer = answer;
    m_bMultiChoice = multiChoice;
    m_falseAnswers = falseAnswers;
    m_testFrequecy = testFrequency;
  }

  @HiveField(0)
  String m_question = "";

  @HiveField(1)
  String m_answer = "";

  @HiveField(2)
  String m_falseAnswers = "";

  @HiveField(3)
  bool m_bMultiChoice = false;

  @HiveField(4)
  String m_testFrequecy = "Never";
}

class MemoryAdapter extends TypeAdapter<Memory>
{
  @override
  final typeId = 0;

  @override
  Memory read(BinaryReader reader) {
    try
    {
      return Memory(question: reader.read(), answer: reader.read(), multiChoice: reader.readBool(), falseAnswers: reader.read(), testFrequency: reader.read());
    }
    catch (e)
    {
      return Memory();
    }
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer.write(obj.m_question);
    writer.write(obj.m_answer);
    writer.writeBool(obj.m_bMultiChoice);
    writer.write(obj.m_falseAnswers);
    writer.write(obj.m_testFrequecy);
  }
}

class Database
{
  static final Database m_database = Database._internal();
  static Box<Memory>? m_memoryBox;

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
  }

  Box<Memory>? getMemoryBox()
  {
    return m_memoryBox;
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
