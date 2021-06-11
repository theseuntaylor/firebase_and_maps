import 'package:flutter/material.dart';

class Incident {
  String longitude;
  String latitude;
  DateTime time;
  String description;

  Incident({
    @required this.longitude,
    @required this.latitude,
    @required this.description,
    @required this.time,
  });
}
