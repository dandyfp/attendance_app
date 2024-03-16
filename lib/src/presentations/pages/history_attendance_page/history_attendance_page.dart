import 'package:attendance_app/src/data/isar_service.dart';
import 'package:attendance_app/src/helpers/date_time_format.dart';
import 'package:attendance_app/src/presentations/shared/ui_helpers.dart';
import 'package:flutter/material.dart';

class HistoryAttendancePage extends StatefulWidget {
  const HistoryAttendancePage({super.key});

  @override
  State<HistoryAttendancePage> createState() => _HistoryAttendancePageState();
}

final isarService = IsarService();

class _HistoryAttendancePageState extends State<HistoryAttendancePage> {
  @override
  void initState() {
    isarService.getAllAttendance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "History Attendance",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: FutureBuilder(
        future: isarService.getAllAttendance(),
        builder: (context, snapshot) {
          return snapshot.data!.isEmpty || snapshot.data == null
              ? const Center(
                  child: Text(
                    "Data is empty",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data?[index];
                      return Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black),
                          ),
                        ),
                        child: ListTile(
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item?.attendanceIn != null
                                        ? "Attendance In: ${FormatDate().formatDate(
                                            item?.attendanceIn,
                                            context: context,
                                            format: 'HH:mm',
                                          )}"
                                        : '-',
                                  ),
                                  horizontalSpace(10),
                                  Text(
                                    item?.attendanceOut != null
                                        ? "Attendance Out: ${FormatDate().formatDate(
                                            item?.attendanceOut,
                                            context: context,
                                            format: 'HH:mm',
                                          )}"
                                        : '-',
                                  ),
                                ],
                              ),
                              Text(
                                item?.locationOffice != null ? "Location Office : ${item?.locationOffice ?? ''}" : '-',
                              ),
                            ],
                          ),
                          title: Text(
                            item?.date != null
                                ? FormatDate().formatDate(
                                    item?.date,
                                    context: context,
                                    format: 'dd-MMMM-yyyy',
                                  )
                                : '-',
                          ),
                        ),
                      );
                    },
                  ),
                );
        },
      ),
    );
  }
}
