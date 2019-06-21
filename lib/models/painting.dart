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
  static final String columnWiki = "wiki";
  static final String columnMedium = "medium";
  static final String columnDimensions = "dimensions";
  static final String columnLastViewed = "lastViewed";

  String id;
  String artist;
  String title;
  String museum;
  String imagePath;
  String text;
  String year;
  String copyright;
  String medium;
  String wiki;
  String dimensions;
  DateTime lastViewed;

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
    wiki = map[columnWiki];
    medium = map[columnMedium];
    dimensions = map[columnDimensions];
    lastViewed = map[lastViewed];
    if (lastViewed != null)
      lastViewed =
          DateTime.fromMillisecondsSinceEpoch(map[lastViewed], isUtc: true);
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
    if (wiki != null) map[columnWiki] = wiki;
    if (medium != null) map[columnMedium] = medium;
    if (dimensions != null) map[columnDimensions] = dimensions;
    if (lastViewed != null)
      map[columnLastViewed] = lastViewed.millisecondsSinceEpoch;

    return map;
  }
}
