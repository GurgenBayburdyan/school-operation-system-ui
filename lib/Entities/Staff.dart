class Staff{
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final int schoolId;


  Staff( {
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.schoolId
  });


  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      schoolId: json['schoolId']
    );
  }
}