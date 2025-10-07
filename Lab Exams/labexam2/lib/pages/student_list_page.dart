import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student.dart';

class StudentListPage extends StatefulWidget {
  const StudentListPage({super.key});

  @override
  _StudentListPageState createState() => _StudentListPageState();
}

class _StudentListPageState extends State<StudentListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Student> _students = [];
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    List<Student> students = await _dbHelper.getStudents();
    if (mounted) {
      setState(() {
        _students = students;
      });
    }
  }

  void _showAddEditDialog({Student? student}) {
    final _formKey = GlobalKey<FormState>();
    String name = student?.name ?? '';
    String email = student?.email ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student == null ? 'Add Student' : 'Edit Student'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Name is required' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value!.isEmpty ? 'Email is required' : null,
                onSaved: (value) => email = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                bool nameExists = await _dbHelper.studentNameExists(
                  name,
                  excludeId: student?.id,
                );
                if (nameExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student name must be unique'),
                    ),
                  );
                  return;
                }
                bool emailExists = await _dbHelper.studentEmailExists(
                  email,
                  excludeId: student?.id,
                );
                if (emailExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student email must be unique'),
                    ),
                  );
                  return;
                }
                Student newStudent = Student(name: name, email: email);
                if (student == null) {
                  await _dbHelper.insertStudent(newStudent);
                } else {
                  newStudent.id = student.id;
                  await _dbHelper.updateStudent(newStudent);
                }
                _loadStudents();
                Navigator.of(context).pop();
              }
            },
            child: Text(student == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent(int id) async {
    await _dbHelper.deleteStudent(id);
    _loadStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification is ScrollUpdateNotification) {
                if (notification.scrollDelta! > 0 && _isFabVisible) {
                  setState(() {
                    _isFabVisible = false;
                  });
                } else if (notification.scrollDelta! < 0 && !_isFabVisible) {
                  setState(() {
                    _isFabVisible = true;
                  });
                }
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _students.length,
              itemBuilder: (context, index) {
                Student student = _students[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                student.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _showAddEditDialog(student: student),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Student'),
                                  content: const Text('Are you sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _deleteStudent(student.id!);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (!_isFabVisible) {
                  setState(() {
                    _isFabVisible = true;
                  });
                }
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
