import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../controllers/task_controller.dart';
import '../models/category_models.dart';
import '../models/task_models.dart';
import '../utils/theme.dart';
import '../widgets/input_field.dart';
import 'add_category_dialog.dart'; 

class AddTaskScreen extends StatefulWidget {

  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override

  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskController _taskController = Get.find<TaskController>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = "Low";
  List<String> priorityList = ["Low", "Medium", "High"];
  List<Category> _categoryObjects = [];
  String? _selectedCategoryName;
  static const String _defaultCategory = "بدون فئة"; 

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.task != null) {
      _titleController.text = widget.task!.title ?? "";
      _noteController.text = widget.task!.description ?? "";
      _selectedDate = DateFormat.yMd().parse(widget.task!.dueDate!);
      _selectedPriority = widget.task!.priority ?? "Low";
      _selectedCategoryName = widget.task!.category ?? _defaultCategory;
    } else {
      _selectedCategoryName = _defaultCategory;
    }
  }

  Future<void> _loadCategories() async {
    var box = Hive.box<Category>('categories_box');

    List<Category> fetchedCategories = box.values.toList();

    Category defaultCat = Category(id: -1, titles: _defaultCategory);
    fetchedCategories.insert(0, defaultCat);

    setState(() {
      _categoryObjects = fetchedCategories;

      if (_selectedCategoryName == null ||
          !_categoryObjects.any((cat) => cat.titles == _selectedCategoryName)) {
        _selectedCategoryName = _defaultCategory;
      }
    });
  }

  void _showAddCategoryDialog() {
    Get.dialog(
      const AddCategoryDialog(),
    ).then((result) {
      if (result == true) {
        _loadCategories();
        Get.snackbar("نجاح", "تمت إضافة الفئة بنجاح وتحديث القائمة.", snackPosition: SnackPosition.BOTTOM);
      }
    });

  }

  @override
  void dispose() {

    _titleController.dispose();

    _noteController.dispose();

    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: _appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(

                widget.task == null ? "Add Task" : "Edit Task",

                style: headingStyle,

              ),
              const SizedBox(height: 10),
              MyInputField(

                title: "Title",

                hint: "Enter your title",

                controller: _titleController,

              ),
              const SizedBox(height: 10),
              MyInputField(

                title: "Description",

                hint: "Enter your description",

                controller: _noteController,

              ),
              const SizedBox(height: 10),
              MyInputField(

                title: "Date",

                hint: DateFormat.yMd().format(_selectedDate),

                widget: IconButton(

                  icon: const Icon(Icons.calendar_today_outlined, color: Colors.grey),

                  onPressed: () {

                    _getDateFromUser();

                  },

                ),

              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Priority",
                      hint: _selectedPriority,
                      widget: DropdownButton<String>(
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                        iconSize: 32,
                        elevation: 4,
                        style: subTitleStyle,
                        underline: Container(height: 0),
                        value: _selectedPriority,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedPriority = newValue!;
                          });
                        },
                        items: priorityList.map<DropdownMenuItem<String>>((
                          String value,
                        ) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  Expanded(
                    child: MyInputField(
                      title: "Category",
                      hint: _selectedCategoryName ?? _defaultCategory,
                      widget: Row(
                        children: [
                          DropdownButton<String>(
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                            iconSize: 32,
                            elevation: 4,
                            style: subTitleStyle,
                            underline: Container(height: 0),
                            value: _selectedCategoryName,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategoryName = newValue;
                                });
                              }
                            },
                            items: _categoryObjects.map<DropdownMenuItem<String>>((Category category,) {
                              return DropdownMenuItem<String>(
                                value: category.titles,
                                child: Text(
                                  category.titles ?? "hi",
                                ),
                              );
                            }).toList(),
                          ),
                          GestureDetector(
                            onTap: _showAddCategoryDialog,
                            child: Icon(
                              Icons.add_circle,
                              color: primaryClr,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 4),
                       ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _validateDate(),
                    child: Container(
                      width: 120,
                        height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),

                        color: primaryClr,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.task == null ? "Create Task" : "Update Task",

                        style: const TextStyle(color: Colors.white),

                      ),

                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

      ),

    );

  }

  _validateDate() {

    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {

      if (widget.task == null) {

        _addTaskToDb();

      } else {

        _updateTaskInDb();

      }

      Get.back();

    } else {

      Get.snackbar(

        "Required",

        "All fields are required !",

        snackPosition: SnackPosition.BOTTOM,

        backgroundColor: Colors.white,

        colorText: pinkClr,

        icon: Icon(Icons.warning_amber_rounded, color: Colors.red),

      );

    }

  }

  _addTaskToDb() async {

    
     await _taskController.addTask(

      task: Task(

        description: _noteController.text,

        title: _titleController.text,

        isCompleted: false,

        category: _selectedCategoryName,
        priority: _selectedPriority,

        dueDate: DateFormat.yMd().format(_selectedDate),

        // createdAt: DateTime.now().toString(),

      ),

    );

    print("My id is " + "");

  }

  _updateTaskInDb() async {

    
    await _taskController.updateTaskInfo(

      Task(

        id: widget.task!.id,

        description: _noteController.text,

        title: _titleController.text,

        isCompleted: widget.task!.isCompleted,

        category: _selectedCategoryName,
        priority: _selectedPriority,

        dueDate: DateFormat.yMd().format(_selectedDate),

        // createdAt: widget.task!.createdAt,

      ),

    );

  }

  PreferredSizeWidget _appBar(BuildContext context) {

    
    return AppBar(

      elevation: 0,

      backgroundColor: context.theme.scaffoldBackgroundColor,

      leading: GestureDetector(

        onTap: () {

          Get.back();

        },

        child: Icon(

          Icons.arrow_back_ios,

          size: 20,

          color: Get.isDarkMode ? Colors.white : Colors.black,

        ),

      ),

      actions: [

        CircleAvatar(

          child: Icon(Icons.person),

          backgroundColor: Colors.grey[200],

        ),

        SizedBox(width: 20),

      ],

    );

  }

  _getDateFromUser() async {

    DateTime? _pickerDate = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2015),

      lastDate: DateTime(2121),

    );

    if (_pickerDate != null) {

      setState(() {

        _selectedDate = _pickerDate;

      });

    } else {

      print("it's null or something is wrong");

    }

  }

}

                                           