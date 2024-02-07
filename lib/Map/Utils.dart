import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as PP;

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

PP.PolylinePoints polylinePoints = PP.PolylinePoints();

Future<double> distanceBetween(LatLng A, LatLng B) async {
  List<LatLng> polylineCoordinates = [];
  String googleAPIKey = "AIzaSyB5qPWFVxzgFufyrDEZuqeoMmfyl4fBX9I";

  PP.PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
    googleAPIKey,
    PP.PointLatLng(A.latitude, A.longitude),
    PP.PointLatLng(B.latitude, B.longitude),
    travelMode: PP.TravelMode.driving,
  );

  if (result.points.isNotEmpty) {
    result.points.forEach((PP.PointLatLng point) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });
  } else {
    print(result.errorMessage);
  }

  print("result");
  print(result);
  print("pollyine asdasd length");
  print(polylineCoordinates.length);

  double totalDistance = 0;
  for (var i = 0; i < polylineCoordinates.length - 1; i++) {
    totalDistance += calculateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude);
  }
  return totalDistance;
}

double speedBetween(LatLng A, LatLng B) {
  return 1;
}

Future<int> timeTaken(LatLng A, LatLng B) async {
  double dbtw = await distanceBetween(A, B);
  return (dbtw / speedBetween(A, B)).ceil();
}

Future<int> batteryUsed(LatLng A, LatLng B) async {
  return timeTaken(A, B);
}
