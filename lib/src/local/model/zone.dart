class Zone {
  final int id;
  final int zoneId;
  final String zoneName;
  final String regionName;

  Zone({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.regionName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'regionName': regionName,
    };
  }

  @override
  String toString() {
    return 'Zone{id: $id, zoneId: $zoneId, zoneName: $zoneName, regionName: $regionName }';
  }
}
