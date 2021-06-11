import 'package:cloud_firestore/cloud_firestore.dart';

Future<CollectionReference> getIncidents() async {
  CollectionReference incidents = Firestore.instance.collection("events");

  return incidents;
}
