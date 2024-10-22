import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

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
  StreamSubscription<Position>? _geolocatorSubscription;
  final MapController _mapController = MapController();
  bool _isFollowingRider = true;
  Timer? _updateTimer;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _currentRiderLocation = widget.currentLocation;
    _startListeningToRiderLocation();
    _setupLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _geolocatorSubscription?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _setupLocationUpdates() async {
    // Request permission if not granted
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // Set up continuous location updates
    _geolocatorSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentRiderLocation = LatLng(position.latitude, position.longitude);
        });

        // Update Firestore with new location
        _updateRiderLocation(position);

        // Move map if following is enabled
        if (_isFollowingRider) {
          _mapController.move(
              _currentRiderLocation!, _mapController.camera.zoom);
        }
      }
    });
  }

  Future<void> _updateRiderLocation(Position position) async {
    final riderId = widget.order['riderId'];
    if (riderId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(riderId).update({
        'gps': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': FieldValue.serverTimestamp(),
        }
      });
    } catch (e) {
      log('Error updating rider location: $e');
    }
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
        }
      }
    });
  }

  // เพิ่มฟังก์ชันสำหรับถ่ายรูป
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo == null) return;

      setState(() => _isUploading = true);

      // อัพโหลดรูปภาพไปยัง Firebase Storage
      final String fileName =
          'order_${widget.order['orderId']}_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';
      final Reference ref =
          FirebaseStorage.instance.ref().child('order_photos').child(fileName);

      final UploadTask uploadTask = ref.putFile(File(photo.path));
      final TaskSnapshot taskSnapshot = await uploadTask;
      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // อัพเดทข้อมูลใน Firestore
      // อัพเดทข้อมูลใน Firestore
      await FirebaseFirestore.instance
          .collection('Product')
          .doc(widget.order['productId'])
          .update({
        'photos': FieldValue.arrayUnion([
          {
            'url': downloadUrl,
            'timestamp': Timestamp
                .now(), // เปลี่ยนจาก FieldValue.serverTimestamp() เป็น Timestamp.now()
          }
        ])
      });

      setState(() {
        _uploadedImageUrl = downloadUrl;
        _isUploading = false;
      });

      if (mounted) {
        _showCustomSnackBar('Photo uploaded successfully',
            backgroundColor: const Color.fromARGB(255, 3, 180, 17));
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        _showCustomSnackBar('Error: ${e.toString()}',
            backgroundColor: const Color.fromARGB(255, 255, 0, 0));
      }
    }
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
        actions: [
          IconButton(
            icon:
                Icon(_isFollowingRider ? Icons.gps_fixed : Icons.gps_not_fixed),
            onPressed: () {
              setState(() {
                _isFollowingRider = !_isFollowingRider;
                if (_isFollowingRider && _currentRiderLocation != null) {
                  _mapController.move(
                      _currentRiderLocation!, _mapController.camera.zoom);
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipientLocationLat != null && recipientLocationLng != null)
              Stack(
                children: [
                  SizedBox(
                    height: 300,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentRiderLocation ??
                            LatLng(recipientLocationLat, recipientLocationLng),
                        initialZoom: 15.0,
                        onMapEvent: (event) {
                          // Disable following when user manually moves the map
                          if (event.source != MapEventSource.mapController) {
                            setState(() => _isFollowingRider = false);
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            if (_currentRiderLocation != null)
                              Marker(
                                point: _currentRiderLocation!,
                                child: const Icon(
                                  Icons.bike_scooter,
                                  color: Color.fromARGB(255, 255, 153, 0),
                                  size: 40,
                                ),
                              ),
                            Marker(
                              point: LatLng(
                                  recipientLocationLat, recipientLocationLng),
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
                  if (_currentRiderLocation != null)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.center_focus_strong,
                            color: Colors.black87),
                        onPressed: () {
                          setState(() => _isFollowingRider = true);
                          _mapController.move(_currentRiderLocation!, 15.0);
                        },
                      ),
                    ),
                ],
              ),
            _buildSection(
              'Product Information',
              [
                _buildInfoRow('Name',
                    widget.productData['productName']?.toString() ?? 'N/A'),
                _buildInfoRow('Price',
                    '${widget.productData['price']?.toString() ?? '50'} ฿'),
              ],
            ),
            _buildSection(
              'Order Information',
              [
                _buildInfoRow(
                    'Sender', widget.order['senderName']?.toString() ?? 'N/A'),
                _buildInfoRow('Recipient',
                    widget.order['recipientName']?.toString() ?? 'N/A'),
                _buildInfoRow('Phone',
                    widget.order['recipientPhone']?.toString() ?? 'N/A'),
                _buildInfoRow('Address',
                    widget.order['address']?['address']?.toString() ?? 'N/A'),
                _buildInfoRow(
                    'Status', widget.order['status']?.toString() ?? 'N/A'),
              ],
            ),
            _buildPhotoButton(),
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

// เพิ่ม Widget สำหรับปุ่มถ่ายรูป
  Widget _buildPhotoButton() {
    return Center(
      // เพิ่ม Center widget
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _isUploading ? null : _takePhoto,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF890E1C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          icon: _isUploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.camera_alt),
          label: Text(_isUploading ? 'Uploading...' : 'Take Photo'),
        ),
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

  void _showCustomSnackBar(String message,
      {Color? backgroundColor, Color? textColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor ?? Colors.white), // กำหนดสีข้อความ
        ),
        backgroundColor: backgroundColor ?? Colors.blue, // กำหนดสีพื้นหลัง
        duration: const Duration(seconds: 3), // ระยะเวลาแสดง
        behavior: SnackBarBehavior.floating, // พฤติกรรมการแสดง
      ),
    );
  }
}
