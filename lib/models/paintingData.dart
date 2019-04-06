class PaintingData {
  static final String tableName = 'paintingsData';
  static final String columnId = "id";
  static final String columnPhash = "phash";
  static final String columnHistogram = "histogram";

  String id;
  String phash;
  String histogram;

  PaintingData();

  // convenience constructor to create a Word object
  PaintingData.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    phash = map[columnPhash];
    histogram = map[columnHistogram];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnPhash: phash, columnHistogram: histogram};

    if (id != null) map[columnId] = id;

    return map;
  }
}
