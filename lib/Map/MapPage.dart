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
  String googleAPIKey = "AIzaSyD7MzSVF3n7LDvDsuMQFPJBdhpQV9B3pog";

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
        SizedBox(
          height: 30,
        ),
        TextButton(
            child: Text("Add Checkpoint"),
            onPressed: () async {
              var place = await PlacesAutocomplete.show(
                  context: context,
                  apiKey: googleAPIKey,
                  mode: Mode.overlay,
                  types: [],
                  strictbounds: false,
                  onError: (err) {
                    print(err);
                  });

              if (place != null) {
                setState(() {
                  location = place.description.toString();
                });

                // form google_maps_webservice package
                final plist = GoogleMapsPlaces(
                  apiKey: googleAPIKey,
                  apiHeaders: await GoogleApiHeaders().getHeaders(),
                  //from google_api_headers package
                );
                String placeid = place.placeId ?? "0";
                final detail = await plist.getDetailsByPlaceId(placeid);
                final geometry = detail.result.geometry!;
                final lat = geometry.location.lat;
                final lang = geometry.location.lng;
                var newlatlang = LatLng(lat, lang);
                addMarker(geometry.location.toString(), newlatlang,
                    detail.result.name);

                // move map camera to selected place with animation
                _controller?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: newlatlang, zoom: 17)));
              }
            }),
        TextButton(
            child: Text("Add Station"),
            onPressed: () async {
              var place = await PlacesAutocomplete.show(
                  context: context,
                  apiKey: googleAPIKey,
                  mode: Mode.overlay,
                  types: [],
                  strictbounds: false,
                  onError: (err) {
                    print(err);
                  });

              if (place != null) {
                setState(() {
                  location = place.description.toString();
                });

                // form google_maps_webservice package
                final plist = GoogleMapsPlaces(
                  apiKey: googleAPIKey,
                  apiHeaders: await GoogleApiHeaders().getHeaders(),
                  //from google_api_headers package
                );
                String placeid = place.placeId ?? "0";
                final detail = await plist.getDetailsByPlaceId(placeid);
                final geometry = detail.result.geometry!;
                final lat = geometry.location.lat;
                final lang = geometry.location.lng;
                var newlatlang = LatLng(lat, lang);
                addSTMarker(geometry.location.toString(), newlatlang,
                    detail.result.name);

                // move map camera to selected place with animation
                _controller?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: newlatlang, zoom: 17)));
              }
            }),
        TextButton(
            child: Text("Compute path"),
            onPressed: () async {
              print("Call unordered path");
              var result = await unordered_path(markersL, markersR, 100);
              var dist = result[0];
              var path = result[1];
              List<LatLng>? coordinates =
                  (path as List)?.map((item) => item as LatLng)?.toList();
              List<LatLng> polylineCoordinates = [];
              String googleAPIKey = "AIzaSyD7MzSVF3n7LDvDsuMQFPJBdhpQV9B3pog";

              for (int i = 0; i < coordinates!.length - 1; i++) {
                PP.PolylineResult res =
                    await polylinePoints.getRouteBetweenCoordinates(
                  googleAPIKey,
                  PP.PointLatLng(
                      coordinates[i].latitude, coordinates[i].longitude),
                  PP.PointLatLng(coordinates[i + 1].latitude,
                      coordinates[i + 1].longitude),
                  travelMode: PP.TravelMode.driving,
                );
                if (res.points.isNotEmpty) {
                  res.points.forEach((PP.PointLatLng point) {
                    polylineCoordinates
                        .add(LatLng(point.latitude, point.longitude));
                  });
                } else {
                  print(res.errorMessage);
                }
              }

              addPolyLine(polylineCoordinates);
              // Toast.show("Minimum time: " + dist.toString(),
              //     duration: Toast.lengthShort, gravity: Toast.bottom);
              // for (int i = 0; i < path.length; i++) {}
              // print(dist);
              // print(path);
            }),
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
      ]),
    );
  }

  // Future<void> _goToTheLake() async {
  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newCameraPosition(kIIIT));
  // }
}
