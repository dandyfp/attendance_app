import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:attendance_app/src/data/isar_service.dart';
import 'package:attendance_app/src/domain/entities/attendance.dart';
import 'package:attendance_app/src/domain/entities/list_attendance.dart';
import 'package:attendance_app/src/helpers/date_time_format.dart';
import 'package:attendance_app/src/helpers/navigator_helper.dart';
import 'package:attendance_app/src/presentations/pages/history_attendance_page/history_attendance_page.dart';
import 'package:attendance_app/src/presentations/shared/images.dart';
import 'package:attendance_app/src/presentations/shared/ui_helpers.dart';
import 'package:attendance_app/src/presentations/components/button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

late CameraPosition initialCameraPosition;
double setLatitude = -6.173110;
double setLongitude = 106.829361;
String locationOffice = 'Gambir, jakarta';
LatLng? latLng;
Position? currentPosition;
LatLng? latLngSelected;
Set<Marker> markers = HashSet<Marker>();

class _HomePageState extends State<HomePage> {
  String date = DateTime.now().toString();
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final isarService = IsarService();
  bool isLoading = false;
  bool isSelectGambir = true;
  bool isSelectBandung = false;
  bool isSelectBatam = false;
  bool attendanceLoading = false;

  Attendance? attendance;

  static CameraPosition cameraPosition = CameraPosition(
    target: LatLng(currentPosition?.latitude ?? 37.42796133580664, currentPosition?.longitude ?? -122.085749655962),
    zoom: 14.4746,
  );

  static CameraPosition position = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(currentPosition?.latitude ?? .43296265331129, currentPosition?.longitude ?? -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization() async {
    isLoading = true;
    var permission = await handleLocationPermission(context);
    if (permission) {
      await _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _getCurrentLocation();
          _goToPosition();
        },
        label: const Text('Get position!'),
        icon: const Icon(Icons.gps_fixed),
      ),
      body: isLoading == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    headerGoogleMap(context),
                    choosePlaceForAttandance(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      verticalSpace(15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Today's Status",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          InkWell(
                            onTap: () {
                              NavigatorHelper.push(context, const HistoryAttendancePage());
                            },
                            child: const Text(
                              "History Attendance",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      verticalSpace(20),
                      containerAttandence(),
                    ],
                  ),
                )
              ],
            ),
    );
  }

  Container headerGoogleMap(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: GoogleMap(
          markers: markers,
          mapType: MapType.normal,
          initialCameraPosition: cameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
    );
  }

  SafeArea choosePlaceForAttandance() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const Center(
                child: Text(
              'Choose a Place for Attendance',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Button(
                  isDisabled: isSelectGambir,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      locationOffice = 'Gambir, jakarta';
                      isSelectGambir = true;
                      isSelectBandung = false;

                      isSelectBatam = false;
                      setLatitude = -6.173110;
                      setLongitude = 106.829361;
                    });
                    //-6.173110, 106.829361.
                  },
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Gambir, Jakarta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Button(
                  isDisabled: isSelectBandung,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      locationOffice = 'Bandung City';
                      isSelectBandung = true;
                      isSelectGambir = false;
                      isSelectBatam = false;
                      setLatitude = -6.932694;
                      setLongitude = 107.627449;
                    });

                    // -6.932694, 107.627449.
                  },
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Bandung City',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Button(
                  isDisabled: isSelectBatam,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  onPressed: () {
                    //1.054507 ,104.004120
                    setState(() {
                      locationOffice = 'Batam City';
                      isSelectBandung = false;
                      isSelectGambir = false;
                      isSelectBatam = true;
                      setLatitude = 1.054507;
                      setLongitude = 104.004120;
                    });
                  },
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Batam City',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container containerAttandence() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
          ),
        ],
      ),
      child: FutureBuilder<Attendance?>(
          future: isarService.getAttendance(),
          builder: (context, snapshot) {
            return Column(
              children: [
                verticalSpace(20),
                Container(
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 15),
                    child: Text(
                      FormatDate().formatDate(snapshot.data?.date ?? date, context: context, format: 'dd-MMMM-yyyy'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                verticalSpace(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Check In',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          snapshot.data?.attendanceIn != null
                              ? FormatDate().formatDate(snapshot.data?.attendanceIn, context: context, format: 'HH:mm')
                              : '-:-',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Check Out',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        Text(
                          snapshot.data?.attendanceOut != null
                              ? FormatDate().formatDate(snapshot.data?.attendanceOut, context: context, format: 'HH:mm')
                              : '-:-',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                verticalSpace(15),
                buttonAttendance(),
                verticalSpace(15)
              ],
            );
          }),
    );
  }

  FutureBuilder<Attendance?> buttonAttendance() {
    return FutureBuilder<Attendance?>(
        future: isarService.getAttendance(),
        builder: (context, snapshot) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Button(
                  isDisabled: snapshot.data?.attendanceIn != null && snapshot.data?.attendanceOut != null,
                  isLoading: attendanceLoading,
                  onPressed: snapshot.data?.attendanceIn != null
                      ? () async {
                          Attendance req = Attendance(
                            id: snapshot.data?.id,
                            attendanceIn: snapshot.data?.attendanceIn,
                            attendanceOut: DateTime.now().toString(),
                            latitude: currentPosition?.latitude,
                            longitude: currentPosition?.longitude,
                            locationOffice: locationOffice,
                            date: snapshot.data?.date,
                          );
                          ListAttendance data = ListAttendance(
                            id: snapshot.data?.id,
                            attendanceIn: snapshot.data?.attendanceIn,
                            attendanceOut: DateTime.now().toString(),
                            latitude: currentPosition?.latitude,
                            longitude: currentPosition?.longitude,
                            locationOffice: locationOffice,
                            date: snapshot.data?.date,
                          );
                          if (calculateDistance(position.target.latitude, position.target.longitude, setLatitude, setLongitude) > 50.0) {
                            AnimatedSnackBar.material("failed attendance because the distance was more than 50 km",
                                    type: AnimatedSnackBarType.warning)
                                .show(context);
                          } else if (snapshot.data?.locationOffice != locationOffice) {
                            AnimatedSnackBar.material("failed attendance because different location", type: AnimatedSnackBarType.warning)
                                .show(context);
                          } else {
                            setState(() {
                              attendanceLoading = true;
                            });
                            isarService.updateListAttendance(data);
                            await isarService.updateAttendance(req);
                            AnimatedSnackBar.material('Attendance success', type: AnimatedSnackBarType.success)
                                // ignore: use_build_context_synchronously
                                .show(context);
                            setState(() {
                              attendanceLoading = false;
                            });
                          }
                        }
                      : () async {
                          ListAttendance data = ListAttendance(
                            attendanceIn: DateTime.now().toString(),
                            latitude: currentPosition?.latitude,
                            longitude: currentPosition?.longitude,
                            locationOffice: locationOffice,
                            date: date,
                          );
                          Attendance req = Attendance(
                            attendanceIn: DateTime.now().toString(),
                            latitude: currentPosition?.latitude,
                            longitude: currentPosition?.longitude,
                            locationOffice: locationOffice,
                            date: date,
                          );
                          if (calculateDistance(position.target.latitude, position.target.longitude, setLatitude, setLongitude) > 50.0) {
                            AnimatedSnackBar.material("failed attendance because the distance was more than 50 km",
                                    type: AnimatedSnackBarType.warning)
                                .show(context);
                          } else {
                            setState(() {
                              attendanceLoading = true;
                            });
                            isarService.saveDataAttendance(data);
                            await isarService.saveAttendance(req);
                            AnimatedSnackBar.material('Attendance success', type: AnimatedSnackBarType.success)
                                // ignore: use_build_context_synchronously
                                .show(context);
                            setState(() {
                              attendanceLoading = false;
                            });
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue,
                  child: Center(
                    child: Text(
                      snapshot.data?.attendanceIn == null ? 'Check In' : 'Check Out',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              verticalSpace(10),
              if (snapshot.data?.attendanceOut != null)
                InkWell(
                  onTap: () {
                    setState(() {
                      attendanceLoading = true;
                    });
                    isarService.cleanDbAttendance();
                    isarService.getAttendance();
                    setState(() {
                      attendanceLoading = false;
                    });
                  },
                  child: const Text(
                    'Delete data',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
            ],
          );
        });
  }

  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    var latLng = LatLng(position.target.latitude, position.target.longitude);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: latLng,
          zoom: 20,
        ),
      ),
    );
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var newLatLang = LatLng(position.latitude, position.longitude);
    setState(() {
      setMarker(newLatLang);
      currentPosition = position;
      isLoading = false;
    });
  }

  Future<bool> handleLocationPermission(BuildContext currentContext) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable the services'),
        ),
      );
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(currentContext).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are denied'),
          ),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied, we cannot request permissions.'),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> setMarker(LatLng coordinate) async {
    latLngSelected = coordinate;
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(50, 50)),
      iconMarker,
    ).then((d) {
      return d;
    });

    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId(coordinate.toString()),
        position: coordinate,
        icon: customIcon,
      ),
    );
    setState(() {});
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
