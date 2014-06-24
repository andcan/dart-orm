import 'package:orm/orm.dart';

class Hardware {
  @Id() int id;
  /**
   * Name of this [Hardware]
   */
  @Persistable() final String name;
  /**
   * Productor of this [Hardware]
   */
  @Persistable(max: 1500) final String productor;
  
  Hardware (String this.name, String this.productor);
}