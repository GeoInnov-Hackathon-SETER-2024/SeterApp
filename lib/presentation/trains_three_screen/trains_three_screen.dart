import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ibrahima_s_application_seter/core/app_export.dart';
import 'package:ibrahima_s_application_seter/widgets/custom_icon_button.dart';

import '../../gtfscompiled.dart';

class TrainsThreeScreen extends ConsumerStatefulWidget {
  const TrainsThreeScreen({Key? key})
      : super(
    key: key,
  );

  @override
  TrainsThreeScreenState createState() => TrainsThreeScreenState();
}

class TrainsThreeScreenState extends ConsumerState<TrainsThreeScreen> {
  Completer<GoogleMapController> googleMapController = Completer();
  List<String> stations = [
    'Dakar',
    'Colobane',
    'Hann',
    'Dalifort',
    'Beaux Maraichers',
    'Thiaroye',
    'Pikine',
    'Yembeul',
    'Keur Mbaye Fall',
    'PNR',
    'Rufisque',
    'Bargny',
    'Diamniadio',
    'AIBD',
  ];

  String departureStation = 'Dakar';
  String arrivalStation = 'PNR';

  // Define markers set
  Set<Marker> _markersdep = {};
  Set<Marker> _markersarr = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          height: 882.v,
          width: double.maxFinite,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 120.v,
                  width: 372.h,
                  margin: EdgeInsets.only(bottom: 242.v),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10.h),
                    boxShadow: [
                      BoxShadow(
                        color: appTheme.black90002.withOpacity(0.08),
                        spreadRadius: 2.h,
                        blurRadius: 2.h,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 482.v,
                  width: double.maxFinite,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      _buildMapSection(context),
                    ],
                  ),
                ),
              ),
              _buildTrainDetailsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
  Widget _buildMapSection(BuildContext context) {
    return SizedBox(
      height: 482.v,
      width: double.maxFinite,
      child: GoogleMap(
        //TODO: Add your Google Maps API key in AndroidManifest.xml and pod file
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            37.43296265331129,
            -122.08832357078792,
          ),
          zoom: 14.4746,
        ),
        onMapCreated: (GoogleMapController controller) {
          googleMapController.complete(controller);
        },
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        markers: _markersdep.union(_markersarr),
      ),
    );
  }

  Future<void> _updateMap() async {
    try {
      final apiClient = GtfsApiClient(
        baseUrl: 'https://api-hackathon.seter.sn/api',
        token: 'p19bkCMOjd4vWyDKI64joB0AyGbosKRZLHrklpdVctfu9WvIvLAVfwi0VRVv6yvf',
      );

      final stopsData = await apiClient.getStops();

      // Parse the text into a list of maps
      final stopsList = _parseStopsData(stopsData);

      final selectedDepartureStop = stopsList.firstWhere(
            (stop) => stop['stop_name'].toLowerCase().contains(departureStation.toLowerCase()),
        orElse: () => throw Exception('Departure station not found'),
      );

      final LatLng departureCoordinates = LatLng(
        double.parse(selectedDepartureStop['stop_lat'].toString()),
        double.parse(selectedDepartureStop['stop_lon'].toString()),
      );

      final GoogleMapController controller = await googleMapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(departureCoordinates));

      // Add a marker for the departure station
      setState(() {
        _markersdep = {
          Marker(
            markerId: MarkerId('departure_station'),
            position: departureCoordinates,
            infoWindow: InfoWindow(
              title: 'Departure Station',
              snippet: selectedDepartureStop['stop_name'],
            ),
          ),
        };
      });

      // Remove previous arrival marker if it exists
      _markersarr.clear();

      // Add a marker for the arrival station if it's different from the departure
      if (arrivalStation != departureStation) {
        final selectedArrivalStop = stopsList.firstWhere(
              (stop) => stop['stop_name'].toLowerCase().contains(arrivalStation.toLowerCase()),
          orElse: () => throw Exception('Arrival station not found'),
        );

        final LatLng arrivalCoordinates = LatLng(
          double.parse(selectedArrivalStop['stop_lat'].toString()),
          double.parse(selectedArrivalStop['stop_lon'].toString()),
        );

        // Add a marker for the arrival station
        setState(() {
          _markersarr = {
            Marker(
              markerId: MarkerId('arrival_station'),
              position: arrivalCoordinates,
              infoWindow: InfoWindow(
                title: 'Arrival Station',
                snippet: selectedArrivalStop['stop_name'],
              ),
            ),
          };
        });

        // Update camera position to show both markers
        final bounds = LatLngBounds(
          southwest: LatLng(
            min(departureCoordinates.latitude, arrivalCoordinates.latitude),
            min(departureCoordinates.longitude, arrivalCoordinates.longitude),
          ),
          northeast: LatLng(
            max(departureCoordinates.latitude, arrivalCoordinates.latitude),
            max(departureCoordinates.longitude, arrivalCoordinates.longitude),
          ),
        );
        controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100.0));
      } else {
        // Update camera position to show only departure marker
        controller.animateCamera(CameraUpdate.newLatLng(departureCoordinates));
      }
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Failed to update map: $e');
      }
    }
  }


  List<Map<String, dynamic>> _parseStopsData(String stopsData) {
    final lines = stopsData.split('\n');
    final stopsList = <Map<String, dynamic>>[];
    // Skip the first line (header) and start parsing from the second line
    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',');
      if (values.length >= 6) {
        try {
          final stop = {
            'stop_id': values[0],
            'stop_code': values[1],
            'stop_name': values[2],
            'stop_desc': values[3],
            'stop_lat': double.parse(values[4]),
            'stop_lon': double.parse(values[5]),
            'location_type': values[6],
            'parent_station': values[7],
            'stop_timezone': values[8],
            'platform_code': values[9],
          };
          stopsList.add(stop);
        } catch (e) {
          print('Error parsing latitude for line: ${lines[i]}');
          print('Values: $values');
          print('Latitude value: ${values[4]}');
          print('Longitude value: ${values[5]}');
          print(e);
        }
      }
    }
    return stopsList;
  }




  Widget _buildTrainDetailsSection(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 46.v),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              ImageConstant.imgGroup23,
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 19.v),
            Padding(
              padding: EdgeInsets.only(left: 38.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Départ".tr,
                    style: CustomTextStyles.titleMediumBlack90002,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 70.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: departureStation,
                        onChanged: (String? newValue) async {
                          setState(() {
                            departureStation = newValue!;
                          });
                          await _updateMap(); // Update the map when the departure station is selected
                        },
                        items: stations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.h),
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.brown, fontSize: 20.0),
                              ),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(color: Colors.brown, fontSize: 20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 6.v),
            Container(
              height: 4.adaptSize,
              width: 4.adaptSize,
              margin: EdgeInsets.only(left: 43.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 4.v),
            Container(
              height: 4.adaptSize,
              width: 4.adaptSize,
              margin: EdgeInsets.only(left: 43.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 3.v),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 293.h,
                child: Divider(
                  color: appTheme.black90002.withOpacity(0.5),
                ),
              ),
            ),
            Container(
              height: 4.adaptSize,
              width: 4.adaptSize,
              margin: EdgeInsets.only(left: 43.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 4.v),
            Container(
              height: 4.adaptSize,
              width: 4.adaptSize,
              margin: EdgeInsets.only(left: 43.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 7.v),
            Padding(
              padding: EdgeInsets.only(left: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Arrivée".tr,
                    style: CustomTextStyles.titleMediumBlack90002,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 70.h),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: DropdownButton<String>(
                        value: arrivalStation,
                        onChanged: (String? newValue) async {
                          setState(() {
                            arrivalStation = newValue!;
                          });
                          await _updateMap();
                        },
                        items: stations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.h),
                              child: Text(
                                value,
                                style: TextStyle(color: Colors.brown, fontSize: 20.0),
                              ),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(color: Colors.brown, fontSize: 20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.v),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Prochain train".tr,
                        style: CustomTextStyles.titleMediumBlack90002,
                      ),
                      SizedBox(height: 10.v),
                      Row(
                        children: [
                          Text(
                            "Matricule:".tr,
                            style: TextStyle(color: Colors.brown, fontSize: 20.0),
                          ),
                          SizedBox(width: 5.h),
                          Text(
                            "123456", // Replace with actual train matricule
                            style: TextStyle(color: Colors.brown, fontSize: 20.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CustomIconButton(
                    height: 30.adaptSize,
                    width: 30.adaptSize,
                    padding: EdgeInsets.all(6.h),
                    decoration: IconButtonStyleHelper.outlineBlackTL15,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgArrowRightPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapAndTrainDetails(BuildContext context) {
    return Column(
      children: [
        _buildMapSection(context),
        SizedBox(height: 20.v), // Adjust the height as needed
        _buildTrainDetailsSection(context),
      ],
    );
  }

}
