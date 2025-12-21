import 'package:hive_flutter/hive_flutter.dart';
import '../models/category_models.dart';
import '../models/task_models.dart';

class HiveHelper {

  static const String _tasksBoxName = 'tasks_box';
  static const String _categoriesBoxName = 'categories_box';

  HiveHelper._privateConstructor();

  static final HiveHelper instance = HiveHelper._privateConstructor();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(CategoryAdapter());
    await Hive.openBox<Task>(_tasksBoxName);
    await Hive.openBox<Category>(_categoriesBoxName);
  }

  Box<Task> get _taskBox => Hive.box<Task>(_tasksBoxName);

  Box<Category> get _categoryBox => Hive.box<Category>(_categoriesBoxName);

  Future<void> addTask(Task? task) async {
    await _taskBox.add(task!);
  }

  List<Task> getAllTasks() {
    return _taskBox.values.toList();
  }

  Future<void> deleteTask(Task task) async {
    await _taskBox.delete(task);
  }

  Future<void> updateTask(int index, Task task) async {
    await _taskBox.putAt(index, task);
  }

  Future<void> toggleCompleted(int index) async {
    Task? task = _taskBox.getAt(index);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
    }
  }

  Future<void> addCategory(Category? categoryName) async {
    if (!_categoryBox.values.contains(categoryName)) {
      await _categoryBox.add(categoryName!);
    }
  }

  List<Category> getCategories() {
    return _categoryBox.values.toList();
  }
}

