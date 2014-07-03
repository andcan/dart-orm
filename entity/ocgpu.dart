import 'package:orm/orm.dart';
import 'gpu.dart';

class OcGpu extends Gpu {
  OcGpu (String name, String productor, int this.offset)
      : super (name, productor);
  
  @Persistable(max: 100 * 1024 * 1024)
  int offset;
}