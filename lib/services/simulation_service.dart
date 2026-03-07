import 'dart:math';
import '../models/city_zone.dart';

class SimulationService {
  final Random random = Random();

  void simulateFlood(List<CityZone> zones) {
    for (var zone in zones) {
      zone.floodRisk = random.nextDouble();
    }
  }

  void simulateTraffic(List<CityZone> zones) {
    for (var zone in zones) {
      zone.trafficDensity = random.nextDouble();
    }
  }
}
