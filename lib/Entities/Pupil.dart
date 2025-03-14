class Pupil {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final int schoolId;

  Pupil(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.dateOfBirth,
      required this.schoolId});

  factory Pupil.fromJson(Map<String, dynamic> json) {
    return Pupil(
        id: json['id'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        dateOfBirth: DateTime.parse(json['dateOfBirth']),
        schoolId: json['schoolId']
    );
  }
}
