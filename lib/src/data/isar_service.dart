import 'package:attendance_app/src/domain/entities/attendance.dart';
import 'package:attendance_app/src/domain/entities/list_attendance.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Future<Isar> db;
  IsarService() {
    db = openDB();
  }

  saveAttendance(Attendance data) async {
    await cleanDbAttendance();

    final isar = await db;
    await isar.writeTxn(() async {
      await isar.attendances.put(data);
      await getAttendance();
    });
  }

  Future<void> updateAttendance(Attendance data) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final result = await isar.attendances.get(data.id!);
      if (result != null) {
        await isar.attendances.put(data);
        await getAttendance();
      }
    });
  }

  Future<void> updateListAttendance(ListAttendance data) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final result = await isar.listAttendances.get(data.id!);
      if (result != null) {
        await isar.listAttendances.put(data);
        await getAttendance();
      }
    });
  }

  saveDataAttendance(ListAttendance data) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.listAttendances.put(data);
    });
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }

  Future<List<ListAttendance>> getAllAttendance() async {
    final isar = await db;
    return await isar.listAttendances.where().findAll();
  }

  Future<Attendance?> getAttendance() async {
    final isar = await db;
    final data = await isar.attendances.where().findFirst();
    return data;
  }

  Stream<List<ListAttendance>> listenToAttendance() async* {
    final isar = await db;
    yield* isar.listAttendances.where().watch();
  }

  Future<void> cleanDbAttendance() async {
    final isar = await db;
    await isar.writeTxn(() => isar.attendances.clear());
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [
          AttendanceSchema,
          ListAttendanceSchema,
        ],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }
}
