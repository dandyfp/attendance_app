import 'package:isar/isar.dart';

part 'attendance.g.dart';

@Collection()
class Attendance {
  Id? id = Isar.autoIncrement;
  String? attendanceIn;
  String? attendanceOut;
  String? date;
  double? latitude;
  double? longitude;
  String? locationOffice;
  Attendance({
    this.id,
    this.attendanceIn,
    this.attendanceOut,
    this.date,
    this.latitude,
    this.longitude,
    this.locationOffice,
  });
}
