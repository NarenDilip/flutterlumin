class Region {
  final int id;
  final int regionId;
  final String regionName;

  Region({
    required this.id,
    required this.regionId,
    required this.regionName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'regionId': regionId,
      'regionName': regionName,
    };
  }

  @override
  String toString() {
    return 'Region{id: $id, regionId: $regionId, name: $regionName }';
  }
}
