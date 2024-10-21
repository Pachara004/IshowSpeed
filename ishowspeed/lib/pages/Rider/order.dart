import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  final String riderId;

  const OrderPage({Key? key, required this.riderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('riderId', isEqualTo: riderId)
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
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!productSnapshot.hasData || !productSnapshot.data!.exists) {
                    log('No product found for productId: $productId');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text('Product ID: $productId'),
                        subtitle: const Text('Product data not found'),
                      ),
                    );
                  }

                  var productData = productSnapshot.data!.data() as Map<String, dynamic>;
                  // var productName = productData['name'] ?? 'Product Name not available';
                  var productPrice = productData['price']?.toString() ?? '50 ฿';
                  var senderName = order['senderName'] ?? 'N/A';
                  var recipientName = order['recipientName'] ?? 'N/A';
                  var shippingAddress = order['recipientLocation']?['address'] ?? 'N/A';
                  var createdAt = order['createdAt'] ?? 'N/A';
                  var status = order['status'] ?? 'N/A';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      leading: const Icon(Icons.delivery_dining, size: 40, color: Color(0xFF890E1C)),
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
                        style: const TextStyle(color: Colors.black54, fontSize: 14),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text('Sender: $senderName', style: _infoTextStyle()),
                              Text('Recipient: $recipientName', style: _infoTextStyle()),
                              Text('Shipping Address: $shippingAddress', style: _infoTextStyle()),
                              Text('Created At: $createdAt', style: _infoTextStyle()),
                              Text('Status: $status', style: _infoTextStyle()),
                            ],
                          ),
                        ),
                        ButtonBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _showOrderDetail(context, order, productData),
                              child: const Text(
                                'View Full Details',
                                style: TextStyle(color: Color(0xFF890E1C)),
                              ),
                            ),
                            TextButton(
                              onPressed: () => _markOrderAsSuccess(orderId, productId),
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
    FirebaseFirestore.instance.collection('orders').doc(orderId).update({
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

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order, Map<String, dynamic> productData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Product Information:', style: TextStyle(fontWeight: FontWeight.bold)),
                // Text('Name: ${productData['name'] ?? 'N/A'}'),
                Text('Price: ${productData['price']?.toString() ?? '50 ฿'}'),
                // Text('Description: ${productData['description'] ?? 'N/A'}'),
                const Divider(),
                const Text('Order Information:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Sender: ${order['senderName'] ?? 'N/A'}'),
                Text('Recipient: ${order['recipientName'] ?? 'N/A'}'),
                Text('Phone: ${order['recipientPhone'] ?? 'N/A'}'),
                Text('Address: ${order['recipientLocation']?['address'] ?? 'N/A'}'),
                Text('Latitude: ${order['recipientLocation']?['latitude'] ?? 'N/A'}'),
                Text('Longitude: ${order['recipientLocation']?['longitude'] ?? 'N/A'}'),
                Text('Created At: ${order['createdAt'] ?? 'N/A'}'),
                Text('Status: ${order['status'] ?? 'N/A'}'),
                Text('Updated At: ${order['updatedAt'] ?? 'N/A'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
