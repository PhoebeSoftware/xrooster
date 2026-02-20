class Payload {
  Payload({required this.name, required this.user, required this.tokenExpiry, this.attendeeId});

  final String name;
  final String user;
  final int tokenExpiry;
  final int? attendeeId;

  factory Payload.fromMap(Map<String, dynamic> map) {
    return Payload(
      name: map['name'] as String,
      user: map['user'] as String,
      tokenExpiry: map['exp'] as int,
      attendeeId: map['atnId'] as int?,
    );
  }
}
