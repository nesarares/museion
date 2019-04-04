class Painting {
  static final String tableName = 'paintings';
  static final String columnId = "id";
  static final String columnArtist = "artist";
  static final String columnTitle = "title";
  static final String columnMuseum = "museum";
  static final String columnImagePath = "imagePath";
  static final String columnText = "text";
  static final String columnYear = "year";
  static final String columnCopyright = "copyright";
  static final String columnMedium = "medium";
  static final String columnDimensions = "dimensions";

  String id;
  String artist;
  String title;
  String museum;
  String imagePath;
  String text;
  String year;
  String copyright;
  String medium;
  String dimensions;

  Painting();

  // convenience constructor to create a Word object
  Painting.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    artist = map[columnArtist];
    title = map[columnTitle];
    museum = map[columnMuseum];
    imagePath = map[columnImagePath];
    text = map[columnText];
    year = map[columnYear];
    copyright = map[columnCopyright];
    medium = map[columnMedium];
    dimensions = map[columnDimensions];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnArtist: artist,
      columnTitle: title,
      columnMuseum: museum,
      columnImagePath: imagePath,
    };

    if (id != null) map[columnId] = id;
    if (text != null) map[columnText] = text;
    if (year != null) map[columnYear] = year;
    if (copyright != null) map[columnCopyright] = copyright;
    if (medium != null) map[columnMedium] = medium;
    if (dimensions != null) map[columnDimensions] = dimensions;

    return map;
  }
}
