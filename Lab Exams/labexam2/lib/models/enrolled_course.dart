class EnrolledCourse {
  int? id;
  int studentId;
  int courseId;

  EnrolledCourse({this.id, required this.studentId, required this.courseId});

  Map<String, dynamic> toMap() {
    return {'id': id, 'studentId': studentId, 'courseId': courseId};
  }

  factory EnrolledCourse.fromMap(Map<String, dynamic> map) {
    return EnrolledCourse(
      id: map['id'],
      studentId: map['studentId'],
      courseId: map['courseId'],
    );
  }
}
