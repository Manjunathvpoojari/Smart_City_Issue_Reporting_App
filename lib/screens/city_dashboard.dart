import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/city_zone.dart';
import '../services/simulation_service.dart';

class CityDashboard extends StatefulWidget {
  @override
  _CityDashboardState createState() => _CityDashboardState();
}

class _CityDashboardState extends State<CityDashboard> {
  final SimulationService simulation = SimulationService();

  List<CityZone> zones = [
    CityZone(name: "Zone A", lat: 12.3051, lng: 76.6551),
    CityZone(name: "Zone B", lat: 12.2950, lng: 76.6390),
    CityZone(name: "Zone C", lat: 12.3100, lng: 76.6500),
  ];

  Set<Circle> getCircles() {
    return zones.map((zone) {
      Color color = Colors.green;

      if (zone.floodRisk > 0.7) {
        color = Colors.red;
      } else if (zone.floodRisk > 0.4) {
        color = Colors.orange;
      }

      return Circle(
        circleId: CircleId(zone.name),
        center: LatLng(zone.lat, zone.lng),
        radius: 500,
        fillColor: color.withOpacity(0.5),
        strokeWidth: 1,
      );
    }).toSet();
  }

  void runFloodSimulation() {
    simulation.simulateFlood(zones);
    setState(() {});
  }

  void runTrafficSimulation() {
    simulation.simulateTraffic(zones);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Digital Twin City Simulator")),

      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(12.3051, 76.6551),
          zoom: 12,
        ),
        circles: getCircles(),
      ),

      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "flood",
            child: Icon(Icons.water),
            onPressed: runFloodSimulation,
          ),

          SizedBox(height: 10),

          FloatingActionButton(
            heroTag: "traffic",
            child: Icon(Icons.traffic),
            onPressed: runTrafficSimulation,
          ),
        ],
      ),
    );
  }
}
