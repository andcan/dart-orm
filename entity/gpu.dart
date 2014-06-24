import 'package:orm/orm.dart';
import 'hardware.dart';

class Gpu extends Hardware {
  Gpu (String name, String productor)
      : super (name, productor);
  
  @Persistable(max: 100 * 1024 * 1024)
  int memorySize;
}