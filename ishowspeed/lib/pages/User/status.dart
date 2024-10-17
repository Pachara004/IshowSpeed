import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DeliveryStatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(16.244966599496927, 103.24976590899573),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [const LatLng(16.244966599496927, 103.24976590899573), const LatLng(16.241501529917333, 103.2575825276931)],
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    const MarkerLayer(
                      markers: [
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(16.244966599496927, 103.24976590899573),
                          child: Icon(Icons.location_on, color: Colors.green, size: 40.0),
                        ),
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: LatLng(16.241501529917333, 103.2575825276931),
                          child: Icon(Icons.location_on, color: Colors.red, size: 40.0),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  left: 10,
                  top: 40,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      // Handle back navigation
                    },
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 40,
                  child: TextButton(
                    child: const Text('Detail', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      // Handle detail view
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusIndicator(Icons.access_time, 'Waiting for delivery', true),
                    _buildStatusIndicator(Icons.check_circle_outline, 'Rider has accepted', true),
                    _buildStatusIndicator(Icons.motorcycle, 'Currently shipping', false),
                    _buildStatusIndicator(Icons.assignment_turned_in, 'completed', false),
                  ],
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/driver_avatar.png'),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Delivered by', style: TextStyle(fontSize: 14, color: Colors.grey)),
                        Text('Mr. Giga Chad', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('0912312', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Shipping history'),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildStatusIndicator(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.red : Colors.red.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
      ],
    );
  }
}