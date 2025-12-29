import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/task_models.dart';

class TaskController extends GetxController {
  
  final String _boxName = "tasks_box";

  @override
  void onReady() {
    super.onReady();
    getTasks();
  }

  var taskList = <Task>[].obs;
  var filteredTaskList = <Task>[].obs;
  var isSearching = false.obs;
  var selectedCategory = 'All'.obs;
  var selectedPriority = 'All'.obs;

  // إضافة مهمة جديدة
  Future<void> addTask({Task? task}) async {
    var box = Hive.box<Task>(_boxName);
    
    await box.add(task!);
    getTasks();
  }

  // جلب المهام
  void getTasks() {
    var box = Hive.box<Task>(_boxName);
    
    taskList.assignAll(box.values.toList());
    filterTasks();
  }

  // حذف مهمة
  Future<void> delete(Task task) async {
    
    await task.delete();
    getTasks();
  }

  // تحديث حالة الاكتمال
  Future<void> markTaskCompleted(Task task) async {
    task.isCompleted = false; 
    await task.save(); 
    getTasks();
  }

  // تحديث بيانات المهمة كاملة
  Future<void> updateTaskInfo(Task task) async {
    await task.save();
    getTasks();
  }

  // تصفية المهام
  void filterTasks() {
    List<Task> tempTasks = taskList;

    if (selectedCategory.value != 'All') {
      tempTasks = tempTasks
          .where((task) => task.category == selectedCategory.value)
          .toList();
    }

    if (selectedPriority.value != 'All') {
      tempTasks = tempTasks
          .where((task) => task.priority == selectedPriority.value)
          .toList();
    }

    filteredTaskList.assignAll(tempTasks);
  }

  // البحث
  void searchTasks(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
      filterTasks();
    } else {
      isSearching.value = true;
      List<Task> tempTasks = taskList.where((task) {
        return (task.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (task.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
      filteredTaskList.assignAll(tempTasks);
    }
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
    filterTasks();
  }

  void updatePriority(String priority) {
    selectedPriority.value = priority;
    filterTasks();
  }
}
