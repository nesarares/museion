import 'package:cloud_firestore/cloud_firestore.dart';

class Museum {
  static final String tableName = 'museums';
  static final String columnId = "id";
  static final String columnTitle = "title";
  static final String columnImageUrl = "imageUrl";
  static final String columnImageLocation = "imageLocation";
  static final String columnWebsite = "website";
  static final String columnHours = "hours";
  static final String columnFacilities = "facilities";
  static final String columnCountry = "country";
  static final String columnCity = "city";
  static final String columnAddress = "address";
  static final String columnCoordinates = "coordinates";

  String id;
  String title;
  String imageUrl;
  String imageLocation;
  String website;
  String hours;
  String facilities;
  String country;
  String city;
  String address;
  GeoPoint coordinates;

  Museum();

  // convenience constructor to create a Word object
  Museum.fromMap(Map<String, dynamic> map, {bool coordinatesString = false}) {
    id = map[columnId];
    title = map[columnTitle];
    imageUrl = map[columnImageUrl];
    imageLocation = map[columnImageLocation];
    website = map[columnWebsite];
    hours = map[columnHours];
    facilities = map[columnFacilities];
    country = map[columnCountry];
    city = map[columnCity];
    address = map[columnAddress];

    if (coordinatesString) {
      String str = map[columnCoordinates];
      if (str == null) return;
      var lst = str.split(';');
      coordinates = GeoPoint(double.parse(lst[0]), double.parse(lst[1]));
    } else {
      coordinates = map[columnCoordinates];
    }
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap({bool coordinatesString = false}) {
    var map = <String, dynamic>{
      columnTitle: title,
      columnImageUrl: imageUrl,
    };

    if (id != null) map[columnId] = id;

    if (imageLocation != null) map[columnImageLocation] = imageLocation;
    if (website != null) map[columnWebsite] = website;
    if (hours != null) map[columnHours] = hours;
    if (facilities != null) map[columnFacilities] = facilities;
    if (country != null) map[columnCountry] = country;
    if (city != null) map[columnCity] = city;
    if (address != null) map[columnAddress] = address;
    if (coordinates != null) {
      if (coordinatesString) {
        map[columnCoordinates] =
            '${coordinates.latitude};${coordinates.longitude}';
      } else {
        map[columnCoordinates] = coordinates;
      }
    }

    return map;
  }
}
