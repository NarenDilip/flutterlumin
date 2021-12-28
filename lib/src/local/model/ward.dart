class Ward {
  final int id;
  final int wardId;
  final String wardName;
  final int zoneId;
  final String zoneName;
  final String regionName;

  Ward({
    required this.id,
    required this.wardId,
    required this.wardName,
    required this.zoneId,
    required this.zoneName,
    required this.regionName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wardId': wardId,
      'wardName': wardName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'regionName': regionName,
    };
  }

  @override
  String toString() {
    return 'Ward{id: $id, wardId: $wardId, wardName: $wardName, zoneId: $zoneId, zoneName: $zoneName, regionName: $regionName }';
  }
}
