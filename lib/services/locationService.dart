import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';
import 'package:open_museum_guide/services/museumService.dart';

class LocationService {
  LocationService._privateConstructor();
  static final LocationService instance = LocationService._privateConstructor();
  static final MuseumService museumService = MuseumService.instance;

  final Distance distance = new Distance();

  Future<String> getCurrentLocation() async {
    var location = new Location();
    LocationData currentLocation;
    try {
      currentLocation = await location.getLocation();
    } on PlatformException catch (e) {
      print(e);
      currentLocation = null;
    }

    if (currentLocation == null) return null;

    double minDist = double.infinity;
    String id;
    museumService.museums.forEach((museum) {
      final double dist = distance.distance(
          new LatLng(currentLocation.latitude, currentLocation.longitude),
          new LatLng(
              museum.coordinates.latitude, museum.coordinates.longitude));
      if (dist < 1000 && dist < minDist) {
        minDist = dist;
        id = museum.id;
      }
      // print('${museum.title}: $dist');
    });

    return id;
  }

  Future<void> detectAndChangeActiveMuseum() async {
    String currentMuseumId = await getCurrentLocation();
    await museumService.changeActiveMuseum(currentMuseumId);
  }
}
