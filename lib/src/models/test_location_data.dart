class LocationData {
  late double latitude; // Latitude, in degrees
  late double longitude; // Longitude, in degrees
  late double accuracy; // Estimated horizontal accuracy of this location, radial, in meters
  late double altitude; // In meters above the WGS 84 reference ellipsoid
  late double speed; // In meters/second
  late double speedAccuracy; // In meters/second, always 0 on iOS
  late double heading; // Heading is the horizontal direction of travel of this device, in degrees
  late double time; // timestamp of the LocationData
  late bool isMock; // Is the location currently mocked
}