class Course {
  int? id;
  String title;

  Course({this.id, required this.title});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title};
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(id: map['id'], title: map['title']);
  }
}
