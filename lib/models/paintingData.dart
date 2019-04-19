class PaintingData {
  static final String tableName = 'paintingsData';
  static final String columnId = "id";
  static final String columnPhash = "phash";
  static final String columnDescriptors = "descriptors";

  String id;
  String phash;
  String descriptors;

  PaintingData();

  // convenience constructor to create a Word object
  PaintingData.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    phash = map[columnPhash];
    descriptors = map[columnDescriptors];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnPhash: phash,
      columnDescriptors: descriptors
    };

    if (id != null) map[columnId] = id;

    return map;
  }
}
