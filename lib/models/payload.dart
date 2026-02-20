class Payload {
  Payload({required this.name, required this.user, this.attendeeId});

  final String name;
  final String user;
  final int? attendeeId;

  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      name: map['name'] as String,
      user: map['user'] as String,
      attendeeId: map['atnId'] as int?,
    );
  }
}
