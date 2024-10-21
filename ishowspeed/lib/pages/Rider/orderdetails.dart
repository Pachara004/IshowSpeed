import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;
  final Map<String, dynamic> productData;
  final LatLng? currentLocation;

  const OrderDetailsPage({
    Key? key,
    required this.order,
    required this.productData,
    this.currentLocation,
  }) : super(key: key);

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  LatLng? _currentRiderLocation;
  StreamSubscription<DocumentSnapshot>? _locationSubscription;
  final MapController _mapController = MapController();
@override
  void initState() {
    super.initState();
    _currentRiderLocation = widget.currentLocation;
    _startListeningToRiderLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

void _startListeningToRiderLocation() {
  final riderId = widget.order['riderId'];
  if (riderId == null) return;

  _locationSubscription = FirebaseFirestore.instance
      .collection('users')
      .doc(riderId)
      .snapshots()
      .listen((snapshot) {
    if (snapshot.exists && mounted) {
      var data = snapshot.data();
      if (data != null && data['gps'] != null) {
        setState(() {
          _currentRiderLocation = LatLng(
            data['gps']['latitude'],
            data['gps']['longitude'],
          );
        });
        
        // Optionally animate the map to follow the rider
        _mapController.move(_currentRiderLocation!, 15.0);
      }
    }
  });

  // Start a timer to get the current location every 10 seconds
  Timer.periodic(Duration(seconds: 1), (timer) async {
    // Check if the userType is "Rider"
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentRiderLocation = LatLng(position.latitude, position.longitude);
      });
      // log(position.toString());
      // _mapController.move(_currentRiderLocation!, 15.0);
  });
}
  @override
  Widget build(BuildContext context) {
    var recipientLocationLat = widget.order['recipientLocation']['latitude'];
    var recipientLocationLng = widget.order['recipientLocation']['longitude'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF890E1C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipientLocationLat != null && recipientLocationLng != null)
              SizedBox(
                height: 300,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(recipientLocationLat, recipientLocationLng),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        if (widget.currentLocation != null)
                          Marker(
                            point: widget.currentLocation!,
                            child: const Icon(
                              Icons.bike_scooter,
                              color: Color.fromARGB(255, 255, 153, 0),
                              size: 40,
                            ),
                          ),
                        Marker(
                          point: LatLng(recipientLocationLat, recipientLocationLng),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            _buildSection(
              'Product Information',
              [
                _buildInfoRow('Name', widget.productData['name']?.toString() ?? 'N/A'),
                _buildInfoRow('Price', '${widget.productData['price']?.toString() ?? '50'} ฿'),
                _buildInfoRow('Description', widget.productData['description']?.toString() ?? 'N/A'),
              ],
            ),
            _buildSection(
              'Order Information',
              [
                _buildInfoRow('Sender', widget.order['senderName']?.toString() ?? 'N/A'),
                _buildInfoRow('Recipient', widget.order['recipientName']?.toString() ?? 'N/A'),
                _buildInfoRow('Phone', widget.order['recipientPhone']?.toString() ?? 'N/A'),
                _buildInfoRow('Address', widget.order['recipientLocation']?['address']?.toString() ?? 'N/A'),
                // _buildInfoRow('Created At', _formatTimestamp(widget.order['createdAt'])),
                _buildInfoRow('Status', widget.order['status']?.toString() ?? 'N/A'),
                // _buildInfoRow('Updated At', _formatTimestamp(widget.order['updatedAt'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF890E1C),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}