import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ishowspeed/services/storage/geolocator_services.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProductTrackingPage extends StatefulWidget {
  final String productId;
  final String currentStatus;

  const ProductTrackingPage({
    Key? key,
    required this.productId,
    required this.currentStatus,
  }) : super(key: key);

  @override
  State<ProductTrackingPage> createState() => _ProductTrackingPageState();
}

class _ProductTrackingPageState extends State<ProductTrackingPage> {
  StreamSubscription<DocumentSnapshot>? _productSubscription;
  StreamSubscription<DocumentSnapshot>? _riderSubscription;

  Map<String, dynamic>? productData;
  Map<String, dynamic>? riderData;
  String? error;
  bool isLoading = true;
  bool _isFollowingRider = true;
  late MapController _mapController;
  LatLng? _currentRiderLocation;
  LatLng? _deliveryLocation;
  Timer? _updateLocationTimer;
  int currentStepIndex = 0;
  LatLng riderLocation = const LatLng(13.7563, 100.5018);

  final List<String> shippingSteps = [
    'Order Placed',
    'in progress',
    'Out for Delivery', //delivering
    'Delivered'
  ];

  final Map<String, IconData> statusIcons = {
    'Order Placed': Icons.assignment_turned_in,
    'in progress': Icons.motorcycle_sharp,
    'Out for Delivery': Icons.motorcycle,
    'Delivered': Icons.check_circle,
  };

  void _subscribeToProduct() {
    _productSubscription = FirebaseFirestore.instance
        .collection('Product')
        .doc(widget.productId)
        .snapshots()
        .listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            if (snapshot.exists) {
              productData = snapshot.data();
              // ตรงนี้คือจุดที่ค่า currentStepIndex ถูก override
              if (productData?['status'] != null) {
                log(productData?['status']);
                setState(() {
                  currentStepIndex =
                      getCurrentStepIndex(productData!['status']);
                });
              }
              _subscribeToRider(productData?['riderId']);
            } else {
              error = 'ไม่พบข้อมูลสินค้า';
            }
            isLoading = false;
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            error = 'เกิดข้อผิดพลาด: $e';
            isLoading = false;
          });
        }
      },
    );
  }

  void _subscribeToRider(String? riderId) {
    _riderSubscription?.cancel();

    if (riderId == null) {
      if (mounted) {
        setState(() {
          riderData = null;
          error = 'ยังไม่มีไรเดอร์รับงาน';
        });
      }
      return;
    }

    _riderSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(riderId)
        .snapshots()
        .listen(
      (snapshot) {
        if (mounted) {
          setState(() {
            if (snapshot.exists) {
              riderData = snapshot.data();
              error = null;
            } else {
              riderData = null;
              error = 'ไม่พบข้อมูลไรเดอร์';
            }
          });
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            error = 'เกิดข้อผิดพลาดในการโหลดข้อมูลไรเดอร์: $e';
          });
        }
      },
    );
  }

  String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }
    return 'N/A';
  }

  int getCurrentStepIndex(String status) {
    final index = shippingSteps.indexOf(status);
    return index >= 0 ? index : 0;
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _subscribeToProduct();

    GeolocatorServices.getCurrentLocation().then((location) {
      if (mounted) {
        setState(() {
          riderLocation = location;
        });
      }
    });
    // สร้าง Timer เพื่ออัปเดตตำแหน่งผู้ส่งทุก 1 วินาที
  _updateLocationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_isFollowingRider && _currentRiderLocation != null) {
      setState(() {
        // เลื่อนไปยังตำแหน่งผู้ส่งทุก ๆ 1 วินาที
        _mapController.move(_currentRiderLocation!, 15.0);
      });
    }
  });
  }

  @override
  void dispose() {
    _productSubscription?.cancel();
    _riderSubscription?.cancel();
    _updateLocationTimer?.cancel();
    super.dispose();
  }

  Widget buildInfoSection(String title, IconData icon, List<String> details) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF890E1C)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...details.map((detail) => Padding(
              padding: const EdgeInsets.only(left: 32, bottom: 4),
              child: Text(
                detail,
                style: const TextStyle(fontSize: 14),
              ),
            )),
      ],
    );
  }

  Widget buildProductDetails(Map<String, dynamic> productData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productData['imageUrl'] != null)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(productData['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            productData['productName'] ?? 'Unknown Product',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            productData['productDetails'] ?? 'No details available',
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(height: 24),
          buildInfoSection(
            'Sender Information',
            Icons.person_outline,
            [
              'Name: ${productData['senderName'] ?? 'N/A'}',
              if (productData['senderLocation'] != null)
                'Location: ${productData['senderLocation'].toString()}',
            ],
          ),
          const SizedBox(height: 16),
          buildInfoSection(
            'Recipient Information',
            Icons.person_pin_circle_outlined,
            [
              'Name: ${productData['recipientName'] ?? 'N/A'}',
              'Phone: ${productData['recipientPhone'] ?? 'N/A'}',
              if (productData['recipientLocation'] != null)
                'Location: ${productData['recipientLocation'].toString()}',
            ],
          ),
          const SizedBox(height: 16),
          buildInfoSection(
            'Delivery Timeline',
            Icons.access_time,
            [
              'Created: ${formatTimestamp(productData['createdAt'])}',
              'Accepted: ${formatTimestamp(productData['acceptedAt'])}',
              'Completed: ${formatTimestamp(productData['completedAt'])}',
              'Last Updated: ${formatTimestamp(productData['updatedAt'])}',
              'Status Update: ${formatTimestamp(productData['statusUpdateTime'])}',
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRiderInfo(Map<String, dynamic> riderData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFFFC809),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF890E1C),
              image: riderData['profileImage'] != null
                  ? DecorationImage(
                      image: NetworkImage(riderData['profileImage']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: riderData['profileImage'] == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Rider: ${riderData['username'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF890E1C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${riderData['rating']?.toStringAsFixed(1) ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${riderData['completedDeliveries'] ?? 0} deliveries',
                      style: const TextStyle(
                        color: Color(0xFF890E1C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (riderData['phone'] != null) {
                // Implement phone call functionality
              }
            },
            icon: const Icon(
              Icons.phone,
              color: Color(0xFF890E1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusTracking(int currentStepIndex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Delivery Status: ${shippingSteps[currentStepIndex]}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(shippingSteps.length, (index) {
              return Expanded(
                child: Column(
                  children: [
                    Icon(
                      statusIcons[shippingSteps[index]] ?? Icons.help_outline,
                      size: 30,
                      color: index <= currentStepIndex
                          ? const Color(0xFF890E1C)
                          : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      shippingSteps[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: index <= currentStepIndex
                            ? const Color(0xFF890E1C)
                            : Colors.grey,
                      ),
                    ),
                    if (index < shippingSteps.length - 1)
                      Container(
                        height: 2,
                        color: index < currentStepIndex
                            ? const Color(0xFF890E1C)
                            : Colors.grey,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: (currentStepIndex + 1) / shippingSteps.length,
            backgroundColor: Colors.grey[300],
            color: const Color(0xFF890E1C),
          ),
          const SizedBox(height: 20),
          Text(
            'Estimated Delivery: ${DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 2)))}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

Widget buildMap(Map<String, dynamic> productData, LatLng riderLocation) {
  _deliveryLocation = productData['deliveryLocation'] != null
      ? LatLng(
          productData['deliveryLocation'].latitude,
          productData['deliveryLocation'].longitude,
        )
      : null;

  _currentRiderLocation = riderLocation;
  _isFollowingRider = true; // ให้เริ่มติดตามตำแหน่งผู้ส่งตั้งแต่แรก

  LatLng center = _currentRiderLocation ?? riderLocation;
  double zoom = 15.0;

  return Stack(
    children: [
      SizedBox(
        height: 300,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            onMapReady: () {
              // เลื่อนไปตำแหน่งผู้ส่งเมื่อแผนที่พร้อม
              if (_isFollowingRider && _currentRiderLocation != null) {
                _mapController.move(_currentRiderLocation!, zoom);
              }
            },
            onPositionChanged: (position, hasGesture) {
              if (hasGesture) {
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
                Marker(
                  point: _currentRiderLocation ?? riderLocation,
                  width: 40,
                  height: 40,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.motorcycle,
                        color: Color(0xFF890E1C),
                        size: 30,
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF890E1C),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              'Rider',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_deliveryLocation != null)
                  Marker(
                    point: _deliveryLocation!,
                    width: 40,
                    height: 40,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFFFFC809),
                          size: 30,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC809),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Delivery',
                            style:
                                TextStyle(color: Colors.black, fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_currentRiderLocation != null && _deliveryLocation != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_currentRiderLocation!, _deliveryLocation!],
                    color: const Color(0xFF890E1C),
                    strokeWidth: 3.0,
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
          child: Column(
            children: [
              FloatingActionButton(
                heroTag: 'centerMap',
                mini: true,
                backgroundColor: Colors.white,
                child: const Icon(Icons.center_focus_strong,
                    color: Colors.black87),
                onPressed: () {
                  setState(() => _isFollowingRider = true);
                  _mapController.move(center, zoom);
                },
              ),
              if (_deliveryLocation != null) const SizedBox(height: 8),
              if (_deliveryLocation != null)
                FloatingActionButton(
                  heroTag: 'showDelivery',
                  mini: true,
                  backgroundColor: const Color(0xFFFFC809),
                  child: const Icon(Icons.location_on, color: Colors.black87),
                  onPressed: () {
                    _mapController.move(_deliveryLocation!, 15.0);
                  },
                ),
            ],
          ),
        ),
    ],
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Tracking'),
        backgroundColor: const Color(0xFF890E1C),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Product')
            .doc(widget.productId)
            .snapshots(),
        builder: (context, productSnapshot) {
          if (productSnapshot.hasError) {
            return Center(child: Text('Error: ${productSnapshot.error}'));
          }

          final productData =
              productSnapshot.data?.data() as Map<String, dynamic>?;

          if (productData == null) {
            return const Center(child: Text('Product not found'));
          }

          final String? riderId = productData['riderId'] as String?;

          if (riderId == null) {
            return const Center(child: Text('No rider assigned yet'));
          }

          if (productData['riderLocation'] != null) {
            final GeoPoint location = productData['riderLocation'];
            riderLocation = LatLng(location.latitude, location.longitude);
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(riderId)
                .snapshots(),
            builder: (context, riderSnapshot) {
              if (riderSnapshot.hasError) {
                return const Center(child: Text('Error loading rider data'));
              }

              final riderData =
                  riderSnapshot.data?.data() as Map<String, dynamic>?;

              if (riderData == null) {
                return const Center(child: Text('Rider data not available'));
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (riderData != null) buildRiderInfo(riderData),
                    buildMap(productData, riderLocation),
                    buildStatusTracking(currentStepIndex),
                    buildProductDetails(productData),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
