import 'package:isar/isar.dart';

part 'list_attendance.g.dart';

@Collection()
class ListAttendance {
  Id? id = Isar.autoIncrement;
  String? attendanceIn;
  String? attendanceOut;
  String? date;
  double? latitude;
  double? longitude;
  String? locationOffice;
  ListAttendance({
    this.id,
    this.attendanceIn,
    this.attendanceOut,
    this.date,
    this.locationOffice,
    this.latitude,
    this.longitude,
  });
}
