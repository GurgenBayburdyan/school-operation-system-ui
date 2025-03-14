import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Entities/Class.dart';
import 'Entities/Pupil.dart';
import 'Entities/School.dart';

class AddClass extends StatefulWidget {
  const AddClass({super.key});

  @override
  AddClassState createState() => AddClassState();
}

class AddClassState extends State<AddClass> {
  TextEditingController gradeController = TextEditingController();
  TextEditingController letterController = TextEditingController();

  List<Class> classes = [];
  List<School> schools = [];
  String classUrl = "http://localhost:8080/classes";
  String schoolUrl = "http://localhost:8080/schools";

  School? selectedSchool;

  School? currentSchool;

  @override
  void initState() {
    super.initState();
    getClasses();
    getSchools();
  }

  dynamic post(int grade, String classLetter) async {
    await http.post(
      Uri.parse(classUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'grade': grade,
        'classLetter': classLetter,
        'schoolId': selectedSchool?.id
      }),
    );

    setState(() {
      getClasses();
    });
  }

  dynamic getClasses() async {
    final response = await http.get(Uri.parse(classUrl));
    List<dynamic> data = json.decode(response.body);
    final currentClasses = data.map((json) => Class.fromJson(json)).toList();
    for (var value in currentClasses) {
      await value.setSchool();
    }
    setState(() {
      classes = currentClasses;
    });
  }

  dynamic getClassesBySchoolId(int schoolId) async {
    final response = await http.get(Uri.parse('$classUrl/school/$schoolId'));
    List<dynamic> data = json.decode(response.body);
    final currentClasses = data.map((json) => Class.fromJson(json)).toList();
    for (var value in currentClasses) {
      await value.setSchool();
    }
    setState(() {
      classes = currentClasses;
    });
  }

  dynamic getSchools() async {
    final response = await http.get(Uri.parse(schoolUrl));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      schools = data.map((json) => School.fromJson(json)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            Row(children: [
              DropdownButton<School>(
                hint: const Text(
                  "Select School",
                  style: TextStyle(color: Colors.brown, fontSize: 16),
                ),
                value: currentSchool,
                onChanged: (School? newSchool) {
                  setState(() {
                    currentSchool = newSchool;
                    getClassesBySchoolId(currentSchool!.id);
                  });
                },
                items: schools.map((School school) {
                  return DropdownMenuItem<School>(
                    value: school,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.brown.shade50,
                      ),
                      child: Text(
                        'Number: ${school.number}, Named After ${school.namedAfter}\nAddress: ${school.address}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
            Expanded(
              child: ListView.builder(
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  var schoolClass = classes[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5.0,
                    color: Colors.brown.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      onTap: () async {},
                      leading: const Icon(Icons.school),
                      title: Text(
                        '${schoolClass.grade} ${schoolClass.classLetter}',
                        style: const TextStyle(
                          color: Colors.brown,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        schoolClass.school,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.brown,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddClassDialog(context),
        backgroundColor: Colors.brown[700],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> showAddClassDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 16.0,
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              width: 400,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Class',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: gradeController,
                    decoration: const InputDecoration(
                      labelText: 'Grade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: letterController,
                    decoration: const InputDecoration(
                      labelText: 'Letter',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<School>(
                    hint: const Text("Select School"),
                    value: selectedSchool,
                    onChanged: (School? newSchool) {
                      setState(() {
                        selectedSchool = newSchool;
                      });
                    },
                    items: schools.map((School school) {
                      return DropdownMenuItem<School>(
                        value: school,
                        child: Text(
                          'School: Number: ${school.number}, Named After: ${school.namedAfter}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.brown,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final grade = gradeController.text;
                          final letter = letterController.text;
                          post(int.parse(grade), letter);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Class',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
