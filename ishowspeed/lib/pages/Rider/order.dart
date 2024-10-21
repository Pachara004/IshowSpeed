import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ishowspeed/pages/Rider/orderdetails.dart';
import 'package:ishowspeed/services/storage/geolocator_services.dart';
import 'package:latlong2/latlong.dart';

class OrderPage extends StatefulWidget {
  final String riderId;

  const OrderPage({Key? key, required this.riderId}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Timer? _locationTimer;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  StreamSubscription<DocumentSnapshot>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    _listenToLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    // Update location every 10 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        var location = await GeolocatorServices.getCurrentLocation();
        if (location != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.riderId)
              .update({
            'gps': {
              'latitude': location.latitude,
              'longitude': location.longitude,
              // 'timestamp': FieldValue.serverTimestamp(),
            },
          });
        }
      } catch (e) {
        log('Error updating location: $e');
      }
    });
  }

  void _listenToLocationUpdates() {
    _locationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.riderId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        var data = snapshot.data();
        if (data != null && data['gps'] != null) {
          var location = data['gps'];
          setState(() {
            _currentLocation = LatLng(
              location['latitude'],
              location['longitude'],
            );
          });
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Product')
            .where('riderId', isEqualTo: widget.riderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders available',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>;
              var productId = order['productId'];
              var orderId = orders[index].id;
              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Product')
                    .doc(productId)
                    .snapshots(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!productSnapshot.hasData ||
                      !productSnapshot.data!.exists) {
                    log('No product found for productId: $productId');
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text('Product ID: $productId'),
                        subtitle: const Text('Product data not found'),
                      ),
                    );
                  }
                  var productData =
                      productSnapshot.data!.data() as Map<String, dynamic>;
                  // var productName = productData['name'] ?? 'Product Name not available';
                  var productPrice = productData['price']?.toString() ?? '50 ฿';
                  var senderName = order['senderName'] ?? 'N/A';
                  var recipientName = order['recipientName'] ?? 'N/A';
                  var shippingAddress =
                      order['recipientLocation']?['address'] ?? 'N/A';
                  var createdAt = order['createdAt'] ?? 'N/A';
                  var status = order['status'] ?? 'N/A';

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.delivery_dining,
                          size: 40, color: Color(0xFF890E1C)),
                      title: Text(
                        senderName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        'Price: $productPrice',
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 14),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text('Sender: $senderName',
                                  style: _infoTextStyle()),
                              Text('Recipient: $recipientName',
                                  style: _infoTextStyle()),
                              Text('Shipping Address: $shippingAddress',
                                  style: _infoTextStyle()),
                              Text('Created At: $createdAt',
                                  style: _infoTextStyle()),
                              Text('Status: $status', style: _infoTextStyle()),
                            ],
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _showOrderDetail(context, order, productData),
                              child: const Text(
                                'View Full Details',
                                style: TextStyle(color: Color(0xFF890E1C)),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _markOrderAsSuccess(orderId, productId),
                              child: const Text(
                                'Done Order',
                                style: TextStyle(color: Color(0xFF28A745)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  TextStyle _infoTextStyle() {
    return const TextStyle(
      fontSize: 14,
      color: Colors.black54,
    );
  }

  void _markOrderAsSuccess(String orderId, String productId) {
    FirebaseFirestore.instance.collection('Product').doc(orderId).update({
      'status': 'success',
    }).then((value) {
      log('Order status updated to success for orderId: $orderId');
    }).catchError((error) {
      log('Failed to update order status: $error');
    });

    FirebaseFirestore.instance.collection('Product').doc(productId).update({
      'status': 'success',
    }).then((value) {
      log('Product status updated to success for productId: $productId');
    }).catchError((error) {
      log('Failed to update product status: $error');
    });
  }

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order,
    Map<String, dynamic> productData) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => OrderDetailsPage(
        order: order,
        productData: productData,
        currentLocation: _currentLocation,
      ),
    ),
  );
}
}
