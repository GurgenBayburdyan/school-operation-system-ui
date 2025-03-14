import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Entities/Class.dart';
import 'Entities/Pupil.dart';
import 'Entities/School.dart';

class AddPupil extends StatefulWidget {
  const AddPupil({super.key});

  @override
  AddPupilState createState() => AddPupilState();
}

class AddPupilState extends State<AddPupil> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  List<Pupil> pupils = [];
  List<School> schools = [];
  List<Class> classes = [];
  List<Class> selectedClasses = [];
  String pupilUrl = "http://localhost:8080/pupils";
  String classUrl = "http://localhost:8080/classes";
  String pupilInClassUrl = "http://localhost:8080/pupilInClass";
  String schoolUrl = "http://localhost:8080/schools";

  Class? selectedClass;
  String schoolClass = "No Class";

  School? selectedSchool;

  School? currentSchool;

  Class? currentClass;

  @override
  void initState() {
    super.initState();
    getSchools();
  }

  dynamic addPupil(
      String firstName, String lastName, String dateOfBirth) async {
    DateTime date = DateTime.parse(dateOfBirth);
    String dateTime = date.toIso8601String();

    await http.post(
      Uri.parse(pupilUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateTime,
        'schoolId': selectedSchool?.id
      }),
    );

    setState(() {
      getPupilsBySchoolId(currentSchool!.id);
    });
  }

  dynamic getPupilsBySchoolId(int schoolId) async {
    final response = await http.get(Uri.parse('$pupilInClassUrl/$schoolId'));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      pupils = data.map((json) => Pupil.fromJson(json)).toList();
    });
  }

  dynamic getPupilsByClassId(int classId) async {
    final response =
        await http.get(Uri.parse('$pupilInClassUrl/classes/$classId'));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      pupils = data.map((json) => Pupil.fromJson(json)).toList();
    });
  }

  dynamic getSchools() async {
    final response = await http.get(Uri.parse(schoolUrl));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      schools = data.map((json) => School.fromJson(json)).toList();
    });
  }

  dynamic getClassesBySchoolId(int schoolId) async {
    final response = await http.get(Uri.parse('$classUrl/school/$schoolId'));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      classes = data.map((json) => Class.fromJson(json)).toList();
      selectedClasses = classes;
    });
  }

  Future<void> getClass(Pupil pupil) async {
    final response = await http.get(Uri.parse('$pupilInClassUrl/${pupil.id}'));
    Map<String, dynamic> data = json.decode(response.body);

    if (data['errorType'] == null) {
      final classResponse =
          await http.get(Uri.parse('$classUrl/${data['classId']}'));
      Map<String, dynamic> classData = json.decode(classResponse.body);

      if (classData['errorType'] == null) {
        setState(() {
          schoolClass = '${classData['grade']} ${classData['classLetter']}';
        });
      }
    } else {
      schoolClass = "No Class";
    }
  }

  dynamic addToClass(Pupil pupil) async {
    if (selectedClass != null) {
      await http.post(
        Uri.parse(pupilInClassUrl),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'schoolClassId': selectedClass!.id,
          'pupilId': pupil.id,
        }),
      );
      setState(() {
        schoolClass =
            selectedClass!.grade.toString() + selectedClass!.classLetter;
      });
    }
  }

  dynamic deleteFromClass(Pupil pupil) async {
    await http.delete(
      Uri.parse('$pupilInClassUrl/${pupil.id}'),
    );
    setState(() {
      schoolClass = "No Class";
      selectedClass = null;
    });
  }

  dynamic deletePupil(Pupil pupil) async {
    await http.put(Uri.parse('$pupilUrl/${pupil.id}'));
    setState(() {
      getPupilsBySchoolId(currentSchool!.id);
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
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                value: currentSchool,
                onChanged: (School? newSchool) {
                  setState(() {
                    currentSchool = newSchool;
                    getPupilsBySchoolId(currentSchool!.id);
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
                        color: Colors.green.shade50,
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
              const SizedBox(
                width: 20,
              ),
              DropdownButton<Class>(
                hint: const Text(
                  "Select Class",
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                value: currentClass,
                onChanged: (Class? newClass) {
                  setState(() {
                    currentClass = newClass;
                    getPupilsByClassId(currentClass!.id);
                  });
                },
                items: selectedClasses.map((Class schoolClass) {
                  return DropdownMenuItem<Class>(
                    value: schoolClass,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green.shade50,
                      ),
                      child: Text(
                        '${schoolClass.grade}${schoolClass.classLetter}',
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
                itemCount: pupils.length,
                itemBuilder: (context, index) {
                  var pupil = pupils[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5.0,
                    color: Colors.green.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      onTap: () async {
                        await getClass(pupil);
                        showPupilDetailsDialog(context, pupil);
                      },
                      leading: const Icon(Icons.account_circle_rounded),
                      title: Text(
                        '${pupil.firstName} ${pupil.lastName}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Date Of Birth: ${pupil.dateOfBirth}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.green,
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
        onPressed: () => showAddPupilDialog(context),
        backgroundColor: Colors.green[700],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> showAddPupilDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 16.0,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  width: 400,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add New Pupil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: dateOfBirthController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.datetime,
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
                              'Number: ${school.number}, Named After ${school.namedAfter} \n'
                              'Address: ${school.address}',
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
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final firstName = firstNameController.text;
                              final lastName = lastNameController.text;
                              final dateOfBirth = dateOfBirthController.text;
                              addPupil(firstName, lastName, dateOfBirth);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[700],
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Pupil',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ));
      },
    );
  }

  Future<void> showPupilDetailsDialog(BuildContext context, Pupil pupil) async {
    showDialog(
      context: context,
      builder: (builder) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 16.0,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                width: 600,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pupil Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('First Name: ${pupil.firstName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        )),
                    const SizedBox(height: 10),
                    Text('Last Name: ${pupil.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        )),
                    const SizedBox(height: 10),
                    Text('Date of Birth: ${pupil.dateOfBirth}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        )),
                    const SizedBox(height: 20),
                    if (schoolClass != "No Class")
                      Text(
                        'Class: $schoolClass',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            deletePupil(pupil);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete Pupil'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addToClass(pupil);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                          ),
                          child: const Text('Add to Class'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
