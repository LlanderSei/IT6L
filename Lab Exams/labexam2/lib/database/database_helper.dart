import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/course.dart';
import '../models/enrolled_course.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = '/storage/emulated/0/Documents/labexam2_villacino.db';
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE enrolled_courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentId INTEGER NOT NULL,
        courseId INTEGER NOT NULL,
        FOREIGN KEY (studentId) REFERENCES students (id),
        FOREIGN KEY (courseId) REFERENCES courses (id)
      )
    ''');
  }

  // Student CRUD
  Future<int> insertStudent(Student student) async {
    Database db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    Database db = await database;
    return await db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    Database db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  // Course CRUD
  Future<int> insertCourse(Course course) async {
    Database db = await database;
    return await db.insert('courses', course.toMap());
  }

  Future<List<Course>> getCourses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('courses');
    return List.generate(maps.length, (i) => Course.fromMap(maps[i]));
  }

  Future<int> updateCourse(Course course) async {
    Database db = await database;
    return await db.update(
      'courses',
      course.toMap(),
      where: 'id = ?',
      whereArgs: [course.id],
    );
  }

  Future<int> deleteCourse(int id) async {
    Database db = await database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  // EnrolledCourse CRUD
  Future<int> insertEnrolledCourse(EnrolledCourse enrolledCourse) async {
    Database db = await database;
    return await db.insert('enrolled_courses', enrolledCourse.toMap());
  }

  Future<List<EnrolledCourse>> getEnrolledCourses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('enrolled_courses');
    return List.generate(maps.length, (i) => EnrolledCourse.fromMap(maps[i]));
  }

  Future<int> updateEnrolledCourse(EnrolledCourse enrolledCourse) async {
    Database db = await database;
    return await db.update(
      'enrolled_courses',
      enrolledCourse.toMap(),
      where: 'id = ?',
      whereArgs: [enrolledCourse.id],
    );
  }

  Future<int> deleteEnrolledCourse(int id) async {
    Database db = await database;
    return await db.delete(
      'enrolled_courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get enrolled courses for a student
  Future<List<EnrolledCourse>> getEnrolledCoursesForStudent(
    int studentId,
  ) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'enrolled_courses',
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
    return List.generate(maps.length, (i) => EnrolledCourse.fromMap(maps[i]));
  }

  // Get students with their enrolled courses (join)
  Future<List<Map<String, dynamic>>> getStudentsWithCourses() async {
    Database db = await database;
    return await db.rawQuery('''
      SELECT s.id as studentId, s.name, s.email, ec.id as enrollmentId, c.id as courseId, c.title
      FROM students s
      LEFT JOIN enrolled_courses ec ON s.id = ec.studentId
      LEFT JOIN courses c ON ec.courseId = c.id
    ''');
  }

  // Check if student name exists
  Future<bool> studentNameExists(String name, {int? excludeId}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'name = ?${excludeId != null ? ' AND id != ?' : ''}',
      whereArgs: excludeId != null ? [name, excludeId] : [name],
    );
    return maps.isNotEmpty;
  }

  // Check if student email exists
  Future<bool> studentEmailExists(String email, {int? excludeId}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'email = ?${excludeId != null ? ' AND id != ?' : ''}',
      whereArgs: excludeId != null ? [email, excludeId] : [email],
    );
    return maps.isNotEmpty;
  }

  // Check if course title exists
  Future<bool> courseTitleExists(String title, {int? excludeId}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'title = ?${excludeId != null ? ' AND id != ?' : ''}',
      whereArgs: excludeId != null ? [title, excludeId] : [title],
    );
    return maps.isNotEmpty;
  }
}
