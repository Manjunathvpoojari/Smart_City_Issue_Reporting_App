import 'package:flutter/material.dart';
import 'screens/city_dashboard.dart';

void main() {
  runApp(CitySimulator());
}

class CitySimulator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Digital Twin City",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CityDashboard(),
    );
  }
}
