// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as PP;
import 'dart:math';
import 'package:toast/toast.dart';

import 'package:stellantis/Map/UnorderedPath.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  GoogleMapController? _controller;

  Set<Marker> markers = Set(); //markers for google map
  List<LatLng> markersL = [];
  List<LatLng> markersR = [];
  PP.PolylinePoints polylinePoints = PP.PolylinePoints();
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction
  String location = "Search Location";
  String googleAPIKey = "AIzaSyB5qPWFVxzgFufyrDEZuqeoMmfyl4fBX9I";

  // ignore: prefer_const_constructors
  static final CameraPosition kIIIT = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(17.4549784, 78.3500765),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  void initState() {
    super.initState();
    Marker x = Marker(
      //add start location marker
      markerId: MarkerId(kIIIT.toString()),
      position: kIIIT.target, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: 'Current location ',
        snippet:
            'International Institute of Information Technology - Hyderabad',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(1.2), //Icon for Marker
    );
    markers.add(x);
    markersL.add(kIIIT.target);
  }

  addMarker(String id, LatLng L, String name) {
    Marker x = Marker(
      //add start location marker
      markerId: MarkerId(id),
      position: L, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: name,
        snippet: 'A checkpoint',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(1.2), //Icon for Marker
    );
    markers.add(x);
    markersL.add(L);
    setState(() {});
  }

  addSTMarker(String id, LatLng L, String name) {
    Marker x = Marker(
      //add start location marker
      markerId: MarkerId(id),
      position: L, //position of marker
      infoWindow: InfoWindow(
        //popup info
        title: name,
        snippet: 'A station',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(6.9), //Icon for Marker
    );
    markers.add(x);
    markersR.add(L);
    setState(() {});
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    // markers = ordermap.forEach((key, value) { })
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Card(
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const SizedBox(
                    width: 300,
                    height: 100,
                    child: Text('Solar energy received'),
                  ),
                ),
              )),
        ),
        Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: kIIIT,
                markers: markers,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (controller) {
                  setState(() {
                    _controller = controller;
                  });
                },
              ),
            ),
          ],
        ),
      ]),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(kIIIT));
  // }
}
