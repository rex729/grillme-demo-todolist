import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/entities/todo_entity.dart';
import '../controllers/todo_controller.dart';

class TodoBottomSheet extends StatefulWidget {
  final TodoEntity? existingTodo;

  const TodoBottomSheet({super.key, this.existingTodo});

  @override
  State<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends State<TodoBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _dueDateController;
  late String _selectedState;
  late String _selectedCategory;

  bool get isEditing => widget.existingTodo != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTodo;
    _titleController = TextEditingController(text: existing?.title ?? '');
    final defaultDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _dueDateController = TextEditingController(
      text: existing?.dueDate ?? defaultDate,
    );
    _selectedState = existing?.state ?? TodoState.todo;
    _selectedCategory = existing?.category ?? TodoCategory.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final initial =
        DateTime.tryParse(_dueDateController.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<TodoController>();
    bool success;
    if (isEditing) {
      success = await controller.editTodo(
        widget.existingTodo!.copyWith(
          title: _titleController.text.trim(),
          dueDate: _dueDateController.text.trim(),
          state: _selectedState,
          category: _selectedCategory,
        ),
      );
    } else {
      success = await controller.addTodo(
        title: _titleController.text.trim(),
        dueDate: _dueDateController.text.trim(),
        state: _selectedState,
        category: _selectedCategory,
      );
    }

    if (success && mounted) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoController = Get.find<TodoController>();

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? '編輯待辦事項' : '新增待辦事項',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // 1. Title 輸入框
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '標題 (Title)',
                  hintText: '請輸入待辦事項標題',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '標題不可為空白';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Due Date 日期選擇器 (yyyy-mm-dd)
              TextFormField(
                controller: _dueDateController,
                readOnly: true,
                onTap: _pickDueDate,
                decoration: const InputDecoration(
                  labelText: '到期日 (Due Date: yyyy-mm-dd)',
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請選擇到期日';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 3. State 下拉選單 (todo, in progress, done)
              DropdownButtonFormField<String>(
                initialValue: _selectedState,
                decoration: const InputDecoration(
                  labelText: '狀態 (State)',
                  border: OutlineInputBorder(),
                ),
                items: TodoState.values
                    .map(
                      (s) => DropdownMenuItem<String>(
                        value: s,
                        child: Text('${TodoState.label(s)} ($s)'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedState = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 4. Category 下拉選單 (company, personal, other)
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: '分類 (Category)',
                  border: OutlineInputBorder(),
                ),
                items: TodoCategory.values
                    .map(
                      (c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text('${TodoCategory.label(c)} ($c)'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 24),

              // 儲存按鈕
              Obx(() {
                final busy = todoController.isSubmitting.value;
                return SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? '儲存變更' : '新增項目'),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
