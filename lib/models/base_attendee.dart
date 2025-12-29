enum AttendeeType { teacher, group }

abstract class BaseAttendee {
  final int id;
  final String code;
  final AttendeeType role;

  BaseAttendee({required this.id, required this.code, required this.role});
}
