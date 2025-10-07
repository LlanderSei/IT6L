import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/enrolled_course.dart';
import 'enrollment_page.dart';

class EnrolledPage extends StatefulWidget {
  const EnrolledPage({super.key});

  @override
  _EnrolledPageState createState() => _EnrolledPageState();
}

class _EnrolledPageState extends State<EnrolledPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _enrollments = [];
  final ScrollController _scrollController = ScrollController();
  bool _isFabVisible = true;

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    List<Map<String, dynamic>> enrollments = await _dbHelper
        .getStudentsWithCourses();
    if (mounted) {
      setState(() {
        _enrollments = enrollments;
      });
    }
  }

  Map<int, List<Map<String, dynamic>>> _groupByStudent() {
    Map<int, List<Map<String, dynamic>>> grouped = {};
    for (var enrollment in _enrollments) {
      int studentId = enrollment['studentId'];
      if (!grouped.containsKey(studentId)) {
        grouped[studentId] = [];
      }
      grouped[studentId]!.add(enrollment);
    }
    return grouped;
  }

  void _deleteEnrollment(int id) async {
    await _dbHelper.deleteEnrolledCourse(id);
    _loadEnrollments();
  }

  @override
  Widget build(BuildContext context) {
    var grouped = _groupByStudent();
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
            child: ListView(
              controller: _scrollController,
              children: grouped.entries.map((entry) {
                int studentId = entry.key;
                List<Map<String, dynamic>> studentEnrollments = entry.value;
                String studentName = studentEnrollments[0]['name'];
                List<String> courseTitles = studentEnrollments
                    .where((e) => e['courseId'] != null)
                    .map((e) => e['title'] as String)
                    .toList();
                List<int> courseIds = studentEnrollments
                    .where((e) => e['courseId'] != null)
                    .map((e) => e['courseId'] as int)
                    .toList();
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
                                studentName,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                courseTitles.isEmpty
                                    ? 'None'
                                    : courseTitles.join(', '),
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
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EnrollmentPage(
                                    studentId: studentId,
                                    courseIds: courseIds,
                                  ),
                                ),
                              ).then((_) => _loadEnrollments()),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Enrollments'),
                                  content: const Text(
                                    'Are you sure you want to delete all enrollments for this student?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        for (var e in studentEnrollments.where(
                                          (e) => e['enrollmentId'] != null,
                                        )) {
                                          await _dbHelper.deleteEnrolledCourse(
                                            e['enrollmentId'],
                                          );
                                        }
                                        _loadEnrollments();
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
              }).toList(),
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EnrollmentPage()),
              ).then((_) => _loadEnrollments()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
