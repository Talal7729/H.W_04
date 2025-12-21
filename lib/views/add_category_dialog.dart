import 'package:flutter/material.dart';
import '../db/hive_helper.dart';
import '../models/category_models.dart';
import '../widgets/input_field.dart';


class AddCategoryDialog extends StatefulWidget {

  const AddCategoryDialog({super.key});

  @override

  State<AddCategoryDialog> createState() => _AddCategoryDialogState();

}

class _AddCategoryDialogState extends State<AddCategoryDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

		

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();

  }

 

  void _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();      
      final Category newCategory = Category(
        titles: _nameController.text.trim(),
      );
      try {
         await HiveHelper.instance.addCategory(newCategory);
        if (mounted) {
          Navigator.of(context).pop(true);          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تمت إضافة الفئة بنجاح (ID: )')),
          );
        }
      } catch (e) {        
        if (mounted) {         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في إضافة الفئة: ${e.toString()}')),
          );
        }
      }
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('إضافة نوع مهمة جديد'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
  		MyInputField(
                title: "Category Type",
               hint: "Enter your Category Type",
                controller: _nameController,
              ),
            ],
          ),
        ),
      ),

      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false), 
          child: const Text('إلغاء'),
        ),
        ElevatedButton(

          onPressed: _saveCategory, 
          child: const Text('حفظ'),

        ),

      ],

    );

  }

}

