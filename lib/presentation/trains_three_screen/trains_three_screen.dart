import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ibrahima_s_application_seter/core/app_export.dart';
import 'package:timezone/timezone.dart' as tz;
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
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

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

  Future<List<String>> _getTrainsWithinHour(String departureStation) async {
    try {
      final apiClient = GtfsApiClient(
        baseUrl: 'https://api-hackathon.seter.sn/api',
        token: 'p19bkCMOjd4vWyDKI64joB0AyGbosKRZLHrklpdVctfu9WvIvLAVfwi0VRVv6yvf',
      );

      final timeData = await apiClient.getStopTimes();
      final stopsList = _parseTimeData(timeData);

      // Get the current hour and minute
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;

      // Get all departure times within an hour of the current time
      final departureTimesWithinHour = stopsList
          .where((stop) {
        final stopHeadsign = stop['stop_headsign'].toLowerCase();
        final departureStationLowerCase = departureStation.toLowerCase();
        // Check if the stop_headsign contains the departure station
        if (stopHeadsign.contains(departureStationLowerCase)) {
          // Check if the departure time is within an hour of the current time
          final departureHour = int.parse(stop['departure_time'].split(':')[0]);
          final departureMinute = int.parse(stop['departure_time'].split(':')[1]);
          if ((departureHour - currentHour).abs() < 1) {
            if (departureHour == currentHour) {
              // Include trains that depart within the next hour, including the current minute
              return departureMinute >= currentMinute;
            } else {
              // Include trains that depart within the next hour
              return true;
            }
          }
        }
        return false;
      })
          .map((stop) => stop['departure_time'] as String)
          .toList();

      // Sort the departure times and remove duplicates
      departureTimesWithinHour.sort();
      final uniqueDepartureTimesWithinHour = departureTimesWithinHour.toSet().toList();

      return uniqueDepartureTimesWithinHour;
    } catch (e) {
      throw Exception('Failed to get trains within an hour: $e');
    }
  }

  Future<void> _scheduleNotifications(List<String> departureTimesWithinHour) async {
    final now = DateTime.now();
    final scheduledNotifications = departureTimesWithinHour.map((departureTime) {
      final hour = int.parse(departureTime.split(':')[0]);
      final minute = int.parse(departureTime.split(':')[1]);
      final scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );
      return flutterLocalNotificationsPlugin.zonedSchedule(
        Random().nextInt(1000), // Notification ID
        'Train Departure', // Notification title
        'Train departing at $departureTime from $departureStation station', // Notification body
        scheduledTime, // Scheduled time
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id', // Channel ID
            'your_channel_name', // Channel name
            //'your_channel_description', // Channel description
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

    }).toList();

    await Future.wait(scheduledNotifications);
  }

  Future<void> _updateMapAndScheduleNotifications() async {
    await _updateMap();
    final departureTimesWithinHour = await _getTrainsWithinHour(departureStation);
    await _scheduleNotifications(departureTimesWithinHour);
  }

  List<Map<String, dynamic>> _parseTimeData(String timeData) {
    final lines = timeData.split('\n');
    final stopsList = <Map<String, dynamic>>[];
    // Skip the first line (header) and start parsing from the second line
    for (var i = 1; i < lines.length; i++) {
      final values = lines[i].split(',');
      if (values.length >= 10) {
        try {
          final stop = {
            'trip_id': values[0],
            'arrival_time': values[1],
            'departure_time': values[2],
            'stop_id': values[3],
            'stop_sequence': values[4],
            'stop_headsign': values[5],
            'pickup_type': values[6],
            'drop_off_type': values[7],
            'shape_dist_traveled': values[8],
            'timepoint': values[9],
          };
          stopsList.add(stop);
        } catch (e) {
          print('Error parsing line: ${lines[i]}');
          print('Values: $values');
          print(e);
        }
      }
    }
    return stopsList;
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
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 400, // Set a fixed height for the train details section
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 19),
              Padding(
                padding: EdgeInsets.only(left: 38),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Départ".tr,
                      style: CustomTextStyles.titleMediumBlack90002,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 70),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: DropdownButton<String>(
                          value: departureStation,
                          onChanged: (String? newValue) async {
                            setState(() {
                              departureStation = newValue!;
                            });
                            await _updateMapAndScheduleNotifications(); // Update the map and schedule notifications
                          },
                          items: stations.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
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
              SizedBox(height: 6),
              Container(
                height: 4,
                width: 4,
                margin: EdgeInsets.only(left: 43),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 4,
                width: 4,
                margin: EdgeInsets.only(left: 43),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 3),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 293,
                  child: Divider(
                    color: appTheme.black90002.withOpacity(0.5),
                  ),
                ),
              ),
              Container(
                height: 4,
                width: 4,
                margin: EdgeInsets.only(left: 43),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 4),
              Container(
                height: 4,
                width: 4,
                margin: EdgeInsets.only(left: 43),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 7),
              Padding(
                padding: EdgeInsets.only(left: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:[
                    Text(
                      "Arrivée".tr,
                      style: CustomTextStyles.titleMediumBlack90002,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 70),
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
                                padding: EdgeInsets.only(left: 10),
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
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Prochains Trains".tr,
                      style: CustomTextStyles.titleMediumBlack90002,
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<List<String>>(
                      future: _getTrainsWithinHour(departureStation),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          final departureTimes = snapshot.data!;
                          return Column(
                            children: departureTimes.map((departureTime) {
                              return Text(
                                departureTime,
                                style: TextStyle(color: Colors.brown, fontSize: 20.0),
                              );
                            }).toList(),
                          );
                        } else {
                          return Text('No data');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
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
