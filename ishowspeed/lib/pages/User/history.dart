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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Get current user immediately
    _currentUser = FirebaseAuth.instance.currentUser;
    
    // Listen for auth changes
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
            _buildProductList('Products you sent', "userId"),
            _buildProductList('Products you received', "recipientId"),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(String title, String filterField) {
    print('Current user ID: ${_currentUser?.uid}'); // Debug print
    
    return Container(
      color: const Color(0xFFFFC809),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Product')
            .where(filterField, isEqualTo: _currentUser!.uid)
            .where("status", whereNotIn: ["waiting"])
            .snapshots(),
        builder: (context, snapshot) {
          print('Snapshot data: ${snapshot.data?.docs.length}'); // Debug print
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('No $title available.'),
              ),
            );
          }

          // Convert docs to list and sort in memory if needed
          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final statusA = (a.data() as Map<String, dynamic>)['status'] as String;
              final statusB = (b.data() as Map<String, dynamic>)['status'] as String;
              return statusA.compareTo(statusB);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              return ProductItem(
                name: data['productName'] ?? 'Unknown Product',
                senderName: data['senderName'] ?? 'Unknown Sender',
                recipientName: data['recipientName'] ?? 'Unknown Recipient',
                imageUrl: data['imageUrl'] ?? '',
                status: data['status'] ?? 'Unknown',
                productId: doc.id,
              );
            },
          );
        },
      ),
    );
  }

Widget ProductItem({
  required String name,
  required String senderName,
  required String recipientName,
  required String imageUrl,
  required String status,
  required String productId,  // Add this parameter
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
                      'Sender: $senderName',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Recipient: $recipientName',
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