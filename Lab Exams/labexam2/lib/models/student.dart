class Student {
  int? id;
  String name;
  String email;

  Student({this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(id: map['id'], name: map['name'], email: map['email']);
  }
}
