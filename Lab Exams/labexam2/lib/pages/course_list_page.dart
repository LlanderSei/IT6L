import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/course.dart';

class CourseListPage extends StatefulWidget {
  const CourseListPage({super.key});

  @override
  _CourseListPageState createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Course> _courses = [];
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    List<Course> courses = await _dbHelper.getCourses();
    if (mounted) {
      setState(() {
        _courses = courses;
      });
    }
  }

  void _showAddEditDialog({Course? course}) {
    final _formKey = GlobalKey<FormState>();
    String title = course?.title ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(course == null ? 'Add Course' : 'Edit Course'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            initialValue: title,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) => value!.isEmpty ? 'Title is required' : null,
            onSaved: (value) => title = value!,
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
                bool exists = await _dbHelper.courseTitleExists(
                  title,
                  excludeId: course?.id,
                );
                if (exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course title must be unique'),
                    ),
                  );
                  return;
                }
                Course newCourse = Course(title: title);
                if (course == null) {
                  await _dbHelper.insertCourse(newCourse);
                } else {
                  newCourse.id = course.id;
                  await _dbHelper.updateCourse(newCourse);
                }
                _loadCourses();
                Navigator.of(context).pop();
              }
            },
            child: Text(course == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _deleteCourse(int id) async {
    await _dbHelper.deleteCourse(id);
    _loadCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
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
          itemCount: _courses.length,
          itemBuilder: (context, index) {
            Course course = _courses[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditDialog(course: course),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Course'),
                              content: const Text('Are you sure?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _deleteCourse(course.id!);
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
      floatingActionButton: _isFabVisible
          ? FloatingActionButton(
              onPressed: () => _showAddEditDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
