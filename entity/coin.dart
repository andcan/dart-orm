import 'package:orm/orm.dart';

class Coin {
  @Id(max: 206) int marketId;
  @Persistable(length: 25) String name;
}