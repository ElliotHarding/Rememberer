import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Memory extends HiveObject
{
  Memory(String question, String answer, String falseAnswers)
  {
    m_question = question;
    m_answer = answer;
    m_falseAnswers = falseAnswers;
  }

  @HiveField(0)
  String m_question = "";

  @HiveField(1)
  String m_answer = "";

  @HiveField(1)
  String m_falseAnswers = "";
}

class MemoryAdapter extends TypeAdapter<Memory>
{
  @override
  final typeId = 0;

  @override
  Memory read(BinaryReader reader) {
    return Memory(reader.read(), reader.read(), reader.read());
  }

  @override
  void write(BinaryWriter writer, Memory obj) {
    writer.write(obj.m_question);
    writer.write(obj.m_answer);
    writer.write(obj.m_falseAnswers);
  }
}
