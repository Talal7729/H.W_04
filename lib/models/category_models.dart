import 'package:hive/hive.dart';

part 'category_models.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {

  @HiveField(0)
  int? id;
  @HiveField(1)
  String? titles;

  Category({this.id, this.titles});

}
