import 'dart:async';

import 'package:bandmates/views/HomeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:search_map_place/search_map_place.dart';

class MapScreen extends StatefulWidget {
  static const routeName = '/map-screen';

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  var location = new Location();
  Completer<GoogleMapController> _mapController = Completer();

  LocationData currentLocation;
  CameraPosition _initialCamera;
  Set<Circle> circles;

  LatLng _setLocation;
  @override
  void initState() {
    super.initState();
    _setLocation =
        LatLng(currentUser.location.latitude, currentUser.location.longitude);
    _initialCamera = CameraPosition(
        target: LatLng(
            currentUser.location.latitude, currentUser.location.longitude),
        zoom: 12);
    circles = Set<Circle>();
    circles.add(Circle(
      strokeWidth: 1,
      radius: 1500,
      fillColor: Color(0xff53172c).withOpacity(0.4),
      circleId: CircleId("Set Location"),
      center:
          LatLng(currentUser.location.latitude, currentUser.location.longitude),
    ));
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getCurrentLocation() async {
    try {
      currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        AlertDialog(
          content: Text(
              "Enable location permissions for this app in phone settings"),
          actions: <Widget>[
            DialogButton(
              child: Text("Close"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      }

      currentLocation = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            myLocationButtonEnabled: true,
            minMaxZoomPreference: MinMaxZoomPreference(12, 12),
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
            circles: circles,
          ),
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width * 0.01,
            right: MediaQuery.of(context).size.width * 0.04,
            child: Center(
              child: Row(children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Flexible(
                  child: SearchMapPlaceWidget(
                    apiKey: "AIzaSyBVY9wwL0hnzcoEN7HTKh41o92PzHZe0wI",
                    location: _initialCamera.target,
                    radius: 30000,
                    placeholder: "Set Your Home Location",
                    onSelected: (place) async {
                      final geolocation = await place.geolocation;
                      setState(() {
                        circles.clear();
                        circles.add(Circle(
                            strokeWidth: 1,
                            radius: 1500,
                            fillColor:
                                Theme.of(context).primaryColor.withOpacity(0.4),
                            circleId: CircleId("Set Location"),
                            center: geolocation.coordinates));
                      });

                      final GoogleMapController controller =
                          await _mapController.future;

                      controller.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: geolocation.coordinates, zoom: 12)));

                      controller.animateCamera(CameraUpdate.newLatLngZoom(
                          geolocation.coordinates, 12));

                      controller.animateCamera(
                          CameraUpdate.newLatLngBounds(geolocation.bounds, 50));

                      setState(() {
                        _setLocation = geolocation.coordinates;
                      });
                    },
                  ),
                ),
              ]),
            ),
          ),
          Positioned.fill(
            bottom: 45,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FloatingActionButton.extended(
                icon: Icon(Icons.check),
                label: Text("Save Location"),
                onPressed: () {
                  GeoFirePoint point = GeoFirePoint(
                      _setLocation.latitude, _setLocation.longitude);
                  print("[MapScreen] " + point.data.toString());

                  Firestore.instance
                      .collection('users')
                      .document(currentUser.uid)
                      .updateData({
                    'location': point.data,
                  });
                  currentUser.location = point;
                  Navigator.pop(context);
                },
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
