class CityZone {
  final String name;
  final double lat;
  final double lng;
  double floodRisk;
  double trafficDensity;

  CityZone({
    required this.name,
    required this.lat,
    required this.lng,
    this.floodRisk = 0,
    this.trafficDensity = 0,
  });
}
