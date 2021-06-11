import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_and_maps/landing/models/Incident.dart';
import 'package:firebase_and_maps/landing/services/uploadIncident.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  GoogleMapController _mapController;
  String _address, _dateTime;

  Location _location = new Location();
  LocationData _currentPosition;

  var _cameraPosition = LatLng(6.5102495, 3.384887);

  TextEditingController longController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode longFocusNode, latFocusNode, desFocusNode = FocusNode();
  List<Incident> items = [];

  @override
  void initState() {
    // get device location
    getDeviceLocation();

    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    var incidents = Firestore.instance.collection("events").snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: incidents,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            items = snapshot.data.documents
                .map(
                  (e) => Incident(
                    longitude: e.data["longitude"],
                    latitude: e.data["latitude"],
                    description: e.data["description"],
                    time: (e.data["time"] as Timestamp).toDate(),
                  ),
                )
                .toList();
            addMarkers();
            return SafeArea(
              child: Stack(
                children: [
                  GoogleMap(
                    markers: Set<Marker>.of(markers),
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    onMapCreated: _onMapCreated,
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      zoom: 15.0,
                      target: _cameraPosition,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: mediaQuery.height * 0.15,
                      width: double.infinity,
                      color: Colors.transparent,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: items.length,
                        onPageChanged: (index) {
                          animateMap(
                            double.tryParse(items[index].latitude),
                            double.tryParse(items[index].longitude),
                          );
                        },
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            animateMap(
                              double.tryParse(items[index].latitude),
                              double.tryParse(items[index].longitude),
                            );
                          },
                          child: Card(
                            child: Column(
                              children: [
                                // holds the date, lat and long of event
                                Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // late and long container
                                      Container(
                                        margin: EdgeInsets.all(10.0),
                                        child: Text(
                                          "Position: ${items[index].latitude}, ${items[index].longitude}",
                                          style: GoogleFonts.asap(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      // date of event
                                      Container(
                                        margin: EdgeInsets.all(10.0),
                                        child: Text(
                                          "Date: ${DateFormat.yMEd("en_Us").format(items[index].time)}",
                                          style: GoogleFonts.asap(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                        bottom: 10.0,
                                      ),
                                      child: Text(
                                        items[index].description,
                                        style: GoogleFonts.asap(
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                    strokeWidth: 5.0,
                    backgroundColor: Color(0xff576663),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Text(
                      "Loading...",
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff6b705c),
        focusColor: Color(0xff6b705c),
        onPressed: () {
          showDialog(
            context: context,
            child: AlertDialog(
              content: Wrap(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                textInputAction: TextInputAction.next,
                                controller: latController,
                                focusNode: latFocusNode,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context)
                                      .requestFocus(desFocusNode);
                                },
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black45),
                                  ),
                                  labelText: "Latitude",
                                  labelStyle: GoogleFonts.asap(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Expanded(
                              child: TextFormField(
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                controller: longController,
                                focusNode: longFocusNode,
                                onFieldSubmitted: (v) {
                                  FocusScope.of(context)
                                      .requestFocus(desFocusNode);
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.black45),
                                  ),
                                  labelText: "Longitude",
                                  labelStyle: GoogleFonts.asap(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: TextFormField(
                          maxLines: 7,
                          textInputAction: TextInputAction.done,
                          controller: descriptionController,
                          focusNode: desFocusNode,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black45),
                            ),
                            filled: true,
                            labelText:
                                "Type in a description about what happened.",
                            labelStyle: GoogleFonts.asap(),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      RaisedButton(
                          color: Color(0xff6b705c),
                          child: Text("Upload Event!"),
                          onPressed: () {
                            Incident incident = Incident(
                              longitude: longController.text,
                              latitude: latController.text,
                              description: descriptionController.text,
                              time: DateTime.now(),
                            );

                            uploadIncident(incident);

                            longController.clear();
                            latController.clear();
                            descriptionController.clear();

                            Navigator.pop(context);
                          })
                    ],
                  )
                ],
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  getDeviceLocation() async {
    bool _isServiceEnabled;
    PermissionStatus _permissionGranted;

    _isServiceEnabled = await _location.serviceEnabled();

    if (!_isServiceEnabled) {
      _isServiceEnabled = await _location.requestService();
      if (!_isServiceEnabled) return;
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _currentPosition = await _location.getLocation();
    _cameraPosition =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);
  }

  void animateMap(double latitude, double longitude) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 15.0,
          target: LatLng(
            latitude,
            longitude,
          ),
        ),
      ),
    );
  }

  addMarkers() {
    items.forEach((element) {
      _add(element);
    });
  }

  List<Marker> markers = [];

  void _add(Incident data) {
    final String markerIdVal = 'marker_id_${data.longitude}${data.latitude}';
    final MarkerId markerId = MarkerId(markerIdVal);

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        double.tryParse(data.latitude),
        double.tryParse(data.longitude),
      ),
      infoWindow: InfoWindow(
        title: markerIdVal,
        snippet: "Someone reported ${data.description} "
            "at ${DateFormat.Hm("en_Us").format(data.time)} "
            "on ${DateFormat.yMEd("en_Us").format(data.time)}",
      ),
      onTap: () {
        //_onMarkerTapped(markerId);
      },
      onDragEnd: (LatLng position) {
        // _onMarkerDragEnd(markerId, position);
      },
    );

    // setState(() {
    markers.add(marker);
    // });
  }
}
