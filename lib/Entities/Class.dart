import 'dart:convert';
import 'package:http/http.dart' as http;

class Class {
  final int id;
  final int grade;
  final String classLetter;
  final int schoolId;

  late String school;

  String url = "http://localhost:8080/schools";

  Class({
    required this.id,
    required this.grade,
    required this.classLetter,
    required this.schoolId,
    required this.school
  });

  factory Class.fromJson(Map<String, dynamic> json) {
    return Class(
      id: json['id'],
      grade: json['grade'] ?? 0,
      classLetter: json['classLetter'] ?? "",
      schoolId: json['schoolId'],
      school: ""
    );
  }

  Future<void> setSchool() async {
    final classResponse = await http.get(Uri.parse('$url/$schoolId'));
    Map<String, dynamic> classData = json.decode(classResponse.body);

    if (classData['errorType'] == null) {
      school = 'School: Number: ${classData['number']}, Named After ${classData['namedAfter']}';
    }
  }
}
