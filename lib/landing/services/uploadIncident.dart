import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_and_maps/landing/models/Incident.dart';

Future uploadIncident(Incident incident) async {
  createIncident(incident);
}

void createIncident(Incident incident) async {
  final _fireStoreInstance = Firestore.instance;

  _fireStoreInstance
      .collection('events')
      .add({
        'longitude': incident.longitude,
        'latitude': incident.latitude,
        'description': incident.description,
        'time': incident.time
      })
      .then((value) => print("incident added!"))
      .catchError((error) => print("failed to add incident"));
}
