import 'package:hive/hive.dart';

part 'task_models.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {

  @HiveField(0)
  int? id;

  @HiveField(1)
  String? title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? priority;

  @HiveField(4)
  String? dueDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  String? category;

  Task({this.id, this.title, this.description, this.priority, this.dueDate, this.isCompleted = false, this.category});

}

// @HiveType(typeId: 1)
// class Category extends HiveObject {
//
//   @HiveField(0)
//   int? id;
//   @HiveField(1)
//   String? titles;
//
//   Category({this.id, this.titles});
//
// }

