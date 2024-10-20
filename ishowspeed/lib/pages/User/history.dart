import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserHistoryPage extends StatefulWidget {
  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User History')),
        body: const Center(child: Text('User not logged in.')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: AppBar(
            backgroundColor: const Color(0xFF890E1C),
            title: const Text(''),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFFC809),
              indicatorWeight: 4.0,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Sender'),
                Tab(text: 'Receiver'),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductList('Products you send', "userId"),
            _buildProductList('The products you received', "recipientId"),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(String title, String filterField) {
    return Container(
      color: const Color(0xFFFFC809),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC809),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .where(filterField, isEqualTo: _currentUser!.uid)
                        .where("status", isEqualTo: "accepted")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No products available.'));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return ProductItem(
                            name: data['productName'] ?? 'Unknown Product',
                            senderName:
                                data['senderName'] ?? 'Unknown senderName',
                            recipientName: data['recipientName'] ??
                                'Unknown RecipientName',
                            imageUrl: data['imageUrl'] ?? 'N/A',
                            status: data['status'] ?? 'Unknown', // เพิ่ม status
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ProductItem widget
  Widget ProductItem({
    required String name,
    required String senderName,
    required String recipientName,
    required String imageUrl,
    required String status, // รับค่า status ที่ส่งมา
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFAB000D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  imageUrl,
                  width: 74,
                  height: 80,
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return const Icon(Icons.error); // Handle loading error
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SenderName: $senderName',
                          style: const TextStyle(color: Colors.white)),
                      Text('Recipient: $recipientName',
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    _showStatusDialog(
                        context, status); // ใช้ค่า status ที่รับมา
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC809),
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Status'),
                ),
              ),
            ],
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  // Add functionality here for clicking on the detail text
                },
                child: const Text(
                  'Click for detail',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 0, 0),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(BuildContext context, String status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // รายการขั้นตอนการจัดส่ง
        List<String> shippingSteps = [
          'Order Placed',
          'Rider Going to Pick Up',
          'Out for Delivery',
          'Delivered'
        ];

        // กำหนดไอคอนแต่ละสถานะ
        Map<String, IconData> statusIcons = {
          'Order Placed': Icons.assignment_turned_in, // ใช้ไอคอน "Order Placed"
          'Rider Going to Pick Up':
              Icons.motorcycle_sharp, // ใช้ไอคอน "Rider Going to Pick Up"
          'Out for Delivery': Icons.motorcycle, // ใช้ไอคอน "truck" แทน "bike"
          'Delivered': Icons.check_circle, // ใช้ไอคอน "Delivered"
        };

        // ตรวจสอบดัชนีสถานะปัจจุบัน
        int currentStepIndex = shippingSteps.indexOf(status);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            padding: const EdgeInsets.all(20), // เพิ่ม padding
            width: 500, // กำหนดความกว้างของ dialog
            height: 400, // กำหนดความสูงของ dialog
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // หัวข้อของ dialog
                const Text(
                  'Shipping Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24, // ขนาดตัวอักษรใหญ่ขึ้น
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // ข้อความสถานะปัจจุบัน
                Text(
                  'Current status: $status',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // แถบขั้นตอนสถานะ
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(shippingSteps.length, (index) {
                    return Column(
                      children: [
                        Icon(
                          statusIcons[shippingSteps[index]],
                          size: 30, // ขนาดไอคอนใหญ่ขึ้น
                          color: index <= currentStepIndex
                              ? Colors.green
                              : Colors.grey,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          shippingSteps[index],
                          style: TextStyle(
                            color: index <= currentStepIndex
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 0.2, // ขนาดตัวอักษรใหญ่ขึ้น
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 20),
                // แถบแสดงสถานะ
                LinearProgressIndicator(
                  value: (currentStepIndex + 1) / shippingSteps.length,
                  color: Colors.green,
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
