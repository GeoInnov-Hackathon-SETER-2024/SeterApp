import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GtfsApiClient {
  final String baseUrl;
  final String token;

  GtfsApiClient({required this.baseUrl, required this.token});

  Future<String> _get(String path) async {
    final response = await http.get(Uri.parse('$baseUrl$path'), headers: {
      'Authorization': token,
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<String> getAgencies() async {
    return _get('/temps-theorique/agency');
  }

  Future<String> getCalendars() async {
    return _get('/temps-theorique/calendar');
  }

  Future<String> getStops() async {
    return _get('/temps-theorique/stop');
  }

  Future<String> getRoutes() async {
    return _get('/temps-theorique/route');
  }

  Future<String> getTrips() async {
    return _get('/temps-theorique/trip');
  }

  Future<String> getStopTimes() async {
    return _get('/temps-theorique/stop-times');
  }
}

class GtfsData {
  List<Agency> agencies;
  List<Calendar> calendars;
  List<Stop> stops;
  List<Route> routes;
  List<Trip> trips;
  List<StopTime> stopTimes;

  GtfsData({
    required this.agencies,
    required this.calendars,
    required this.stops,
    required this.routes,
    required this.trips,
    required this.stopTimes,
  });

  factory GtfsData.fromJson(Map<String, dynamic> json) {
    return GtfsData(
      agencies: (json['agencies'] as List).map((e) => Agency.fromJson(e)).toList(),
      calendars: (json['calendars'] as List).map((e) => Calendar.fromJson(e)).toList(),
      stops: (json['stops'] as List).map((e) => Stop.fromJson(e)).toList(),
      routes: (json['routes'] as List).map((e) => Route.fromJson(e)).toList(),
      trips: (json['trips'] as List).map((e) => Trip.fromJson(e)).toList(),
      stopTimes: (json['stop_times'] as List).map((e) => StopTime.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agencies': agencies.map((e) => e.toJson()).toList(),
      'calendars': calendars.map((e) => e.toJson()).toList(),
      'stops': stops.map((e) => e.toJson()).toList(),
      'routes': routes.map((e) => e.toJson()).toList(),
      'trips': trips.map((e) => e.toJson()).toList(),
      'stop_times': stopTimes.map((e) => e.toJson()).toList(),
    };
  }

  static GtfsData fromJsonString(String jsonString) =>
      GtfsData.fromJson(json.decode(jsonString));

  String toJsonString() => json.encode(toJson());
}

class Agency {
  final String id;
  final String name;
  final String url;
  final String timezone;
  final String? phone;
  final String? email;

  Agency({
    required this.id,
    required this.name,
    required this.url,
    required this.timezone,
    this.phone,
    this.email,
  });

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['agency_id'],
      name: json['agency_name'],
      url: json['agency_url'],
      timezone: json['agency_timezone'],
      phone: json['agency_phone'],
      email: json['agency_email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agency_id': id,
      'agency_name': name,
      'agency_url': url,
      'agency_timezone': timezone,
      'agency_phone': phone,
      'agency_email': email,
    };
  }
}

class Calendar {
  final String serviceId;
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;
  final String startDate;
  final String endDate;

  Calendar({
    required this.serviceId,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.startDate,
    required this.endDate,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) {
    return Calendar(
      serviceId: json['service_id'],
      monday: json['monday'] == 1,
      tuesday: json['tuesday'] == 1,
      wednesday: json['wednesday'] == 1,
      thursday: json['thursday'] == 1,
      friday: json['friday'] == 1,
      saturday: json['saturday'] == 1,
      sunday: json['sunday'] == 1,
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'monday': monday ? 1 : 0,
      'tuesday': tuesday ? 1 : 0,
      'wednesday': wednesday ? 1 : 0,
      'thursday': thursday ? 1 : 0,
      'friday': friday ? 1 : 0,
      'saturday': saturday ? 1 : 0,
      'sunday': sunday ? 1 : 0,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}

class Stop {
  final String stopId;
  final String stopCode;
  final String stopName;
  final String stopDesc;
  final double stopLat;
  final double stopLon;
  final int locationType;
  final String? parentStation;
  final String? stopTimezone;
  final String? platformCode;

  Stop({
    required this.stopId,
    required this.stopCode,
    required this.stopName,
    required this.stopDesc,
    required this.stopLat,
    required this.stopLon,
    required this.locationType,
    required this.parentStation,
    required this.stopTimezone,
    required this.platformCode,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      stopId: json['stop_id'],
      stopCode: json['stop_code'],
      stopName: json['stop_name'],
      stopDesc: json['stop_desc'],
      stopLat: json['stop_lat'].toDouble(),
      stopLon: json['stop_lon'].toDouble(),
      locationType: json['location_type'],
      parentStation: json['parent_station'],
      stopTimezone: json['stop_timezone'],
      platformCode: json['platform_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stop_id': stopId,
      'stop_code': stopCode,
      'stop_name': stopName,
      'stop_desc': stopDesc,
      'stop_lat': stopLat,
      'stop_lon': stopLon,
      'location_type': locationType,
      'parent_station': parentStation,
      'stop_timezone': stopTimezone,
      'platform_code': platformCode,
    };
  }
}

class Route {
  final String routeId;
  final String agencyId;
  final String routeShortName;
  final String routeLongName;
  final int routeType;
  final int routeSortOrder;

  Route({
    required this.routeId,
    required this.agencyId,
    required this.routeShortName,
    required this.routeLongName,
    required this.routeType,
    required this.routeSortOrder,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      routeId: json['route_id'],
      agencyId: json['agency_id'],
      routeShortName: json['route_short_name'],
      routeLongName: json['route_long_name'],
      routeType: json['route_type'],
      routeSortOrder: json['route_sort_order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'agency_id': agencyId,
      'route_short_name': routeShortName,
      'route_long_name': routeLongName,
      'route_type': routeType,
      'route_sort_order': routeSortOrder,
    };
  }
}

class Trip {
  final String routeId;
  final String serviceId;
  final String tripId;
  final String tripHeadsign;
  final String tripShortName;
  final int directionId;

  Trip({
    required this.routeId,
    required this.serviceId,
    required this.tripId,
    required this.tripHeadsign,
    required this.tripShortName,
    required this.directionId,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      routeId: json['route_id'],
      serviceId: json['service_id'],
      tripId: json['trip_id'],
      tripHeadsign: json['trip_headsign'],
      tripShortName: json['trip_short_name'],
      directionId: json['direction_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'service_id': serviceId,
      'trip_id': tripId,
      'trip_headsign': tripHeadsign,
      'trip_short_name': tripShortName,
      'direction_id': directionId,
    };
  }
}

class StopTime {
  final String tripId;
  final String arrivalTime;
  final String departureTime;
  final String stopId;
  final int stopSequence;
  final String stopHeadsign;
  final int pickupType;
  final int dropOffType;
  final int shapeDistTraveled;
  final int timepoint;

  StopTime({
    required this.tripId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopId,
    required this.stopSequence,
    required this.stopHeadsign,
    required this.pickupType,
    required this.dropOffType,
    required this.shapeDistTraveled,
    required this.timepoint,
  });

  factory StopTime.fromJson(Map<String, dynamic> json) {
    return StopTime(
      tripId: json['trip_id'],
      arrivalTime: json['arrival_time'],
      departureTime: json['departure_time'],
      stopId: json['stop_id'],
      stopSequence: json['stop_sequence'],
      stopHeadsign: json['stop_headsign'],
      pickupType: json['pickup_type'],
      dropOffType: json['drop_off_type'],
      shapeDistTraveled: json['shape_dist_traveled'],
      timepoint: json['timepoint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_id': tripId,
      'arrival_time': arrivalTime,
      'departure_time': departureTime,
      'stop_id': stopId,
      'stop_sequence': stopSequence,
      'stop_headsign': stopHeadsign,
      'pickup_type': pickupType,
      'drop_off_type': dropOffType,
      'shape_dist_traveled': shapeDistTraveled,
      'timepoint': timepoint,
    };
  }
}

void main() {
  final apiClient = GtfsApiClient(
    baseUrl: 'https://api-hackathon.seter.sn/api',
    token: 'p19bkCMOjd4vWyDKI64joB0AyGbosKRZLHrklpdVctfu9WvIvLAVfwi0VRVv6yvf',
  );

  apiClient.getAgencies().then((data) {
    if (kDebugMode) {
      print('Agencies: $data');
    }
  });

  apiClient.getCalendars().then((data) {
    if (kDebugMode) {
      print('Calendars: $data');
    }
  });

  apiClient.getStops().then((data) {
    if (kDebugMode) {
      print('Stops: $data');
    }
  });

  apiClient.getRoutes().then((data) {
    if (kDebugMode) {
      print('Routes: $data');
    }
  });

  apiClient.getTrips().then((data) {
    if (kDebugMode) {
      print('Trips: $data');
    }
  });

  apiClient.getStopTimes().then((data) {
    if (kDebugMode) {
      print('Stop Times: $data');
    }
  });
}
