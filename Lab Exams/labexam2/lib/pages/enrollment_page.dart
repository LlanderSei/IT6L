import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrolled_course.dart';

class EnrollmentPage extends StatefulWidget {
  final int? enrollmentId;
  final int? studentId;
  final List<int>? courseIds;

  const EnrollmentPage({
    super.key,
    this.enrollmentId,
    this.studentId,
    this.courseIds,
  });

  @override
  _EnrollmentPageState createState() => _EnrollmentPageState();
}

class _EnrollmentPageState extends State<EnrollmentPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Student> _students = [];
  List<Course> _courses = [];
  int? _selectedStudentId;
  List<int> _selectedCourseIds = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.studentId != null) {
      _selectedStudentId = widget.studentId;
    }
    if (widget.courseIds != null) {
      _selectedCourseIds = widget.courseIds!;
    }
  }

  Future<void> _loadData() async {
    List<Student> students = await _dbHelper.getStudents();
    List<Course> courses = await _dbHelper.getCourses();
    setState(() {
      _students = students;
      _courses = courses;
    });
  }

  void _save() async {
    if (_selectedStudentId == null || _selectedCourseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a student and at least one course'),
        ),
      );
      return;
    }

    if (widget.studentId == null) {
      // Add new enrollments
      for (int courseId in _selectedCourseIds) {
        EnrolledCourse enrolledCourse = EnrolledCourse(
          studentId: _selectedStudentId!,
          courseId: courseId,
        );
        await _dbHelper.insertEnrolledCourse(enrolledCourse);
      }
    } else {
      // Edit: delete old enrollments for this student and add new
      List<EnrolledCourse> oldEnrollments = await _dbHelper
          .getEnrolledCoursesForStudent(widget.studentId!);
      for (var e in oldEnrollments) {
        await _dbHelper.deleteEnrolledCourse(e.id!);
      }
      for (int courseId in _selectedCourseIds) {
        EnrolledCourse enrolledCourse = EnrolledCourse(
          studentId: _selectedStudentId!,
          courseId: courseId,
        );
        await _dbHelper.insertEnrolledCourse(enrolledCourse);
      }
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.enrollmentId == null ? 'Enroll Student' : 'Edit Enrollment',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: _selectedStudentId,
              decoration: const InputDecoration(labelText: 'Select Student'),
              items: _students.map((student) {
                return DropdownMenuItem<int>(
                  value: student.id,
                  child: Text('${student.name} (${student.email})'),
                );
              }).toList(),
              onChanged: widget.studentId == null
                  ? (value) => setState(() => _selectedStudentId = value)
                  : null,
              validator: (value) =>
                  value == null ? 'Please select a student' : null,
            ),
            const SizedBox(height: 16),
            const Text('Select Courses:'),
            Expanded(
              child: ListView(
                children: _courses.map((course) {
                  return CheckboxListTile(
                    title: Text(course.title),
                    value: _selectedCourseIds.contains(course.id),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedCourseIds.add(course.id!);
                        } else {
                          _selectedCourseIds.remove(course.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
