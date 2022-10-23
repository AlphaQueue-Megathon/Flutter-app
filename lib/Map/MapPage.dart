// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as PP;
import 'dart:math';

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
    markers.add(Marker(
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
    ));
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

  addPolyLine(List<LatLng> polylineCoordinates) {
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
                addMarker(
                    detail.hashCode.toString(), newlatlang, detail.result.name);

                // move map camera to selected place with animation
                _controller?.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: newlatlang, zoom: 17)));
              }
            }),
        TextButton(
            child: Text("Compute path"),
            onPressed: () async {
              print("Call unordered path");
              var result =
                  await unordered_path(markersL, [], Random().nextInt(101));
              var dist = result[0];
              var path = result[1];
              print(dist);
              print(path);
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
