import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  final String riderId; // Rider ID ที่ใช้ในการค้นหาออเดอร์ที่ Rider รับ

  const OrderPage({Key? key, required this.riderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders') // สมมติว่าคุณมี collection ชื่อ 'orders'
            .where('riderId', isEqualTo: riderId) // เงื่อนไขแสดงเฉพาะออเดอร์ที่ rider รับ
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          // รายการออเดอร์ที่ Rider รับ
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index].data() as Map<String, dynamic>; // เข้าถึงข้อมูลในรูปแบบ Map
              
              // ใช้ค่าเริ่มต้นหากฟิลด์ไม่พบ
              var productDetails = order['productDetails'] ?? 'Product Details not available';
              var senderName = order['senderName'] ?? 'N/A';
              var recipientName = order['recipientName'] ?? 'N/A';
              var recipientLocation = order['recipientLocation'] ?? {};
              var shippingAddress = recipientLocation['address'] ?? 'N/A';
              var createdAt = order['createdAt'] ?? 'N/A';
              var status = order['status'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.delivery_dining, size: 40, color: Color(0xFF890E1C)),
                  title: Text(
                    productDetails,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sender: $senderName', style: const TextStyle(color: Colors.black54)),
                      Text('Recipient: $recipientName', style: const TextStyle(color: Colors.black54)),
                      Text('Shipping Address: $shippingAddress', style: const TextStyle(color: Colors.black54)),
                      Text('Created At: $createdAt', style: const TextStyle(color: Colors.black54)),
                      Text('Status: $status', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF890E1C)),
                    onPressed: () {
                      _showOrderDetail(context, order);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showOrderDetail(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product: ${order['productDetails'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Sender: ${order['senderName'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Recipient: ${order['recipientName'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Phone: ${order['recipientPhone'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Address: ${order['recipientLocation']?['address'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Latitude: ${order['recipientLocation']?['latitude'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Longitude: ${order['recipientLocation']?['longitude'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Created At: ${order['createdAt'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Status: ${order['status'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
              Text('Updated At: ${order['updatedAt'] ?? 'N/A'}', style: const TextStyle(color: Colors.black)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
