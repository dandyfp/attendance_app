import 'dart:async';
import 'dart:collection';

import 'package:attendance_app/src/presentations/shared/images.dart';
import 'package:attendance_app/src/presentations/shared/ui_helpers.dart';
import 'package:attendance_app/src/presentations/widget/button.dart';
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
LatLng? latLng;
Position? currentPosition;
LatLng? latLngSelected;
Set<Marker> markers = HashSet<Marker>();

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

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
    handleLocationPermission(context);
    _getCurrentLocation();
    super.initState();
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
        icon: const Icon(Icons.directions_boat),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 2,
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
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                verticalSpace(15),
                const Text(
                  "Today's Status",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                verticalSpace(20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      verticalSpace(20),
                      Container(
                        decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 15),
                          child: Text(
                            '3 February 2024',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Check In',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                '08:00',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Check Out',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Text(
                                '17:00',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      verticalSpace(15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Button(
                          onPressed: () {},
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.blue,
                          child: const Center(
                            child: Text(
                              'Check In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      verticalSpace(15)
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _goToPosition() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(position));
  }

  _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var newLatLang = LatLng(position.latitude, position.longitude);
    setState(() {
      setMarker(newLatLang);
      currentPosition = position;
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
    /* if (addressData != null) {
      subAdministrativeArea = address.subAdministrativeArea;
      locality = address.locality;
      fullAddress = addressData;
    } else {
      subAdministrativeArea = address.subAdministrativeArea;
      locality = address.locality;
      fullAddress = '${address.street}, ${address.locality}, ${address.administrativeArea}, ${address.country}';
    } */
    latLngSelected = coordinate;
    BitmapDescriptor customIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
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
}
