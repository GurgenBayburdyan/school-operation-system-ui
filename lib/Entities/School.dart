class School {
  final int id;
  final int number;
  final String address;
  final String namedAfter;
  final String photoUrl;

  School({
    required this.id,
    required this.number,
    required this.address,
    required this.namedAfter,
    required this.photoUrl,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
        id: json['id'],
        number: json['number'],
        address: json['address'],
        namedAfter: json['namedAfter'],
        photoUrl: json['photoUrl']
    );
  }
}
