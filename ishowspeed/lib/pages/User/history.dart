import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ishowspeed/pages/User/status.dart';

class UserHistoryPage extends StatefulWidget {
  @override
  _UserHistoryPageState createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  int _selectedIndex = 0;
  late TabController _tabController;
  String? _phoneNumber;
  String? _username;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    log("message");
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        log(user.toString());
        setState(() {
          _currentUser = user;
        });

        // Log ข้อมูลผู้ใช้
        log("User ID: ${_currentUser!.uid}");
        log("Email: ${_currentUser!.email}");
        log("Phone: ${_currentUser!.phoneNumber}");

        // ดึงข้อมูลผู้ใช้จาก Firestore
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        setState(() {
          _username = userDoc.data()?['username'] ??
              'Guest'; // ถ้าไม่มี username จะแสดง Guest
          _phoneNumber = userDoc.data()?['phone'];
        });

        // Log ข้อมูลโปรไฟล์ (หากมี)
        log(_phoneNumber.toString());
        log("Username: $_username");
        log("Phone: ${_currentUser!.phoneNumber}");
      }
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
           _buildSenderTab(),
          _buildReceiverTab(),
          ],
        ),
      ),
    );
  }

 Widget _buildSenderTab() {
    log(_phoneNumber.toString());
    return Container(
      color: const Color(0xFFFFC809),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .where("userId", isEqualTo: _currentUser?.uid)
                        .where("status", isNotEqualTo: "waiting")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No products available.'));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return ProductItem(
                            context: context,
                            sender:
                                data['senderName'] ?? _username ?? 'Unknown',
                            name: data['productName'] ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'] ?? 'Unknown',
                            details: data['productDetails'] ??
                                'No details available.',
                            recipientPhone: data['recipientPhone'],
                            productId: data['productId'],
                            status: data['status'],
                            data: data,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiverTab() {
    return Container(
      color: const Color(0xFFFFC809),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Product')
                        .where("recipientPhone",
                            isEqualTo:
                                _phoneNumber) // ตรวจสอบว่า recipientPhone ตรงกับ _phoneNumber
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('No products available.'));
                      }

                      return Column(
                        children: snapshot.data!.docs.map((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          log(data.toString());
                          log(_phoneNumber.toString());
                          return ProductItem(
                            context: context,
                            sender: data['senderName'] ?? 'Unknown',
                            name: data['productName'] ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'] ?? 'Unknown',
                            details: data['productDetails'] ??
                                'No details available.',
                            recipientPhone: data['recipientPhone'],
                            productId: data['productId'],
                            status: data['status'],
                            data: data,
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget ProductItem({
  required BuildContext context, // รับ context
  required String sender,
  required String recipient,
  required String name,
  required String imageUrl,
  required String details,
  required String recipientPhone,
  required String status,
  required String productId,
  required Map<String, dynamic> data,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
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
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 74,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 74,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    )
                  : Container(
                      width: 74,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product: $name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sender: $sender',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Recipient: $recipient',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductTrackingPage(
                        productId: productId,
                        currentStatus: status,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC809),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Track Order'),  // Changed text from 'Status' to 'Track Order'
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
}