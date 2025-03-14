import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:school_operation_system_ui/Entities/Class.dart';
import 'Entities/School.dart';
import 'Entities/Staff.dart';

class AddStaff extends StatefulWidget {
  const AddStaff({super.key});

  @override
  AddStaffState createState() => AddStaffState();
}

class AddStaffState extends State<AddStaff> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();

  List<Staff> staffList = [];
  List<School> schools = [];
  List<Class> classes = [];

  String staffUrl = "http://localhost:8080/staff";
  String classUrl = "http://localhost:8080/classes";
  String headmasterUrl = "http://localhost:8080/headmasters";
  String teacherUrl = "http://localhost:8080/teachers";
  String schoolUrl = "http://localhost:8080/schools";

  Class? selectedClass;

  bool isTeacher = false;
  bool isHeadmaster = false;

  String classId = "No Class";
  String? schoolClass;

  School? selectedSchool;

  int? teacherId;

  School? currentSchool;


  @override
  void initState() {
    super.initState();
    get();
    getClasses();
  }

  dynamic getPupilsBySchoolId(int schoolId) async {
    final response = await http.get(Uri.parse('$staffUrl/schools/$schoolId'));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      staffList = data.map((json) => Staff.fromJson(json)).toList();
    });
  }

  dynamic getClasses() async {
    final response = await http.get(Uri.parse(classUrl));
    List<dynamic> data = json.decode(response.body);
    final currentClasses = data.map((json) => Class.fromJson(json)).toList();
    for (var value in currentClasses) {
      value.setSchool();
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

  dynamic addStaff(
      String firstName, String lastName, String dateOfBirth) async {
    DateTime date = DateTime.parse(dateOfBirth);
    String dateTime = date.toIso8601String();

    await http.post(
      Uri.parse(staffUrl),
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
      get();
    });
  }

  dynamic getClassesBySchoolId(int schoolId) async {
    final response = await http.get(Uri.parse('$classUrl/school/$schoolId'));
    List<dynamic> data = json.decode(response.body);
    setState(() {
      classes = data.map((json) => Class.fromJson(json)).toList();
    });
  }

  dynamic get() async {
    staffList.clear();
    final response = await http.get(Uri.parse(staffUrl));

    List<dynamic> data = json.decode(response.body);
    setState(() {
      staffList = data.map((json) => Staff.fromJson(json)).toList();
    });
  }

  dynamic makeTeacher(Staff staff) async {
    final response = await http.post(
      Uri.parse(teacherUrl),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode({'staffId': staff.id}),
    );
    setState(() {
      isTeacher = true;
      teacherId = json.decode(response.body)['teacherId'];
    });
    checkIfHeadmaster(staff);
  }

  Future<void> checkIfTeacher(Staff staff) async {
    final response = await http.get(Uri.parse('$teacherUrl/${staff.id}'));
    final data = json.decode(response.body);
    if (data['errorType'] == null) {
      setState(() {
        isTeacher = true;
        teacherId = data['id'];
      });
    }
  }

  Future<void> checkIfHeadmaster(Staff staff) async {
    final response = await http.get(Uri.parse('$headmasterUrl/${staff.id}'));
    final data = json.decode(response.body);
    if (data['errorType'] == null) {
      setState(() {
        isHeadmaster = true;
        classId = json.decode(response.body)['classId'].toString();
      });
    } else {
      setState(() {
        isHeadmaster = false;
      });
    }
  }

  dynamic makeHeadmaster(Class schoolClass) async {
    final response = await http.post(
      Uri.parse(headmasterUrl),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode({
        'teacherId': teacherId,
        'classId': schoolClass.id,
      }),
    );

    final data = json.decode(response.body);

    if (data['errorType']) {
      setState(() {
        isHeadmaster = true;
        classId = schoolClass.id.toString();
      });
    }
  }

  Future<void> getClass() async {
    final response = await http.get(Uri.parse('$classUrl/$classId'));
    Map<String, dynamic> data = json.decode(response.body);

    if (data['errorType'] == null) {
      setState(() {
        String grade = data['grade'].toString();
        String classLetter = data['classLetter'].toString();
        schoolClass = '$grade $classLetter';
      });
    }
  }

  dynamic deleteStaff(Staff staff) async {
    await http.delete(Uri.parse('$staffUrl/${staff.id}'));
    setState(() {
      get();
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
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                value: currentSchool,
                onChanged: (School? newSchool) {
                  setState(() {
                    currentSchool = newSchool;
                    getPupilsBySchoolId(currentSchool!.id);
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
                        color: Colors.blue.shade50,
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
                itemCount: staffList.length,
                itemBuilder: (context, index) {
                  var staff = staffList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5.0,
                    color: Colors.blue.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 12.0),
                      onTap: () {
                        showStaffDetailsDialog(context, staff);
                      },
                      leading: const Icon(Icons.account_box),
                      title: Text(
                        '${staff.firstName} ${staff.lastName}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Date Of Birth: ${staff.dateOfBirth}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.blue,
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
        onPressed: () => showAddStaffDialog(context),
        backgroundColor: Colors.blue[900],
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> showAddStaffDialog(BuildContext context) async {
    await getSchools();

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
                      'Add New Staff',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final firstName = firstNameController.text;
                            final lastName = lastNameController.text;
                            final dateOfBirth = dateOfBirthController.text;
                            addStaff(firstName, lastName, dateOfBirth);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add Staff',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            )
        );
      },
    );
  }

  Future<void> showStaffDetailsDialog(BuildContext context, Staff staff) async {
    setState(() {
      isTeacher = false;
      isHeadmaster = false;
    });

    await checkIfTeacher(staff);
    await checkIfHeadmaster(staff);

    if (isHeadmaster) {
      await getClass();
    }

    await getClassesBySchoolId(staff.schoolId);

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
                      'Staff Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('First Name: ${staff.firstName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        )),
                    const SizedBox(height: 10),
                    Text('Last Name: ${staff.lastName}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        )),
                    const SizedBox(height: 10),
                    Text('Date of Birth: ${staff.dateOfBirth}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade800,
                        )),
                    const SizedBox(height: 10),
                    if (isTeacher && !isHeadmaster)
                      DropdownButton<Class>(
                        hint: const Text("Select Class"),
                        value: selectedClass,
                        onChanged: (Class? newClass) {
                          setState(() {
                            selectedClass = newClass;
                          });
                        },
                        items: classes.map((Class schoolClass) {
                          return DropdownMenuItem<Class>(
                            value: schoolClass,
                            child: Text(
                              '${schoolClass.grade} ${schoolClass.classLetter} \n${schoolClass.school}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                    if (isHeadmaster)
                      Text('Class: $schoolClass',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade800,
                          )),
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
                          onPressed: isTeacher
                              ? null
                              : () {
                                  makeTeacher(staff);
                                  Navigator.pop(context);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isTeacher ? Colors.grey : Colors.green[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Make Teacher',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: isTeacher && !isHeadmaster
                              ? () {
                                  makeHeadmaster(selectedClass!);
                                  Navigator.pop(context);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isTeacher && !isHeadmaster
                                ? Colors.green[700]
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Make Headmaster',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            deleteStaff(staff);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[700],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Delete Staff',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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
