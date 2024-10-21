import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ishowspeed/pages/Rider/order.dart';
import 'package:ishowspeed/pages/Rider/profilerider.dart';

// Model class for RecipientLocation
class RecipientLocation {
  final String address;
  final double latitude;
  final double longitude;

  RecipientLocation({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory RecipientLocation.fromMap(Map<String, dynamic> map) {
    return RecipientLocation(
      address: map['address'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class RiderHomePage extends StatefulWidget {
  @override
  _RiderHomePageState createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  int _selectedIndex = 0;
  User? _currentUser;
  String? _profileImageUrl;
  String? _username;
  String? _phone;
  List<DocumentSnapshot> _products = [];
  bool _isLoading = true;
  bool _hasActiveOrder = false; // New variable to track active orders

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        log('Current user ID: ${user.uid}');
        setState(() {
          _currentUser = user;
        });

        await _fetchUserData();
        await _fetchProducts();
      } else {
        log('No user logged in');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error in _initializeUser: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      log('User data fetched: ${userDoc.data()}');

      setState(() {
        _profileImageUrl = userDoc.data()?['profileImage'] ?? '';
        _username = userDoc.data()?['username'] ?? 'Guest';
        _phone = userDoc.data()?['phone'];
      });
    } catch (e) {
      log('Error fetching user data: $e');
    }
  }

  Future<void> _fetchProducts() async {
    try {
      log('Fetching products...');

      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .where("status", isEqualTo: "waiting")
          .get();

      log('Products fetched: ${productSnapshot.docs.length}');

      productSnapshot.docs.forEach((doc) {
        log('Product data: ${doc.data()}');
      });
      _hasActiveOrder = await _checkActiveOrders();
      if (mounted) {
        setState(() {
          _products = productSnapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

// Add new method to check for active orders
  Future<bool> _checkActiveOrders() async {
    try {
      QuerySnapshot activeOrders = await FirebaseFirestore.instance
          .collection('Product')
          .where('riderId', isEqualTo: _currentUser!.uid)
          .where('status', whereIn: ['in_progress', 'accepted']).get();

      return activeOrders.docs.isNotEmpty;
    } catch (e) {
      log('Error checking active orders: $e');
      return false;
    }
  }

  Future<void> _acceptOrder(String productId) async {
    try {
      // ตรวจสอบสถานะผลิตภัณฑ์ก่อนที่จะรับงาน
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('Product')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        String status = productSnapshot['status'];

        // ตรวจสอบว่าผลิตภัณฑ์ถูกยอมรับแล้วหรือไม่
        if (status == 'accepted') {
          ScaffoldMessenger.of(context).showSnackBar(
            // ignore: prefer_const_constructors
            SnackBar(
              content: const Text(
                'This order has already been accepted.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors
                  .orange, // ใช้สีส้มเพื่อแสดงสถานะที่ไม่สามารถดำเนินการได้
              duration: const Duration(seconds: 3),
            ),
          );
          return; // ออกจากฟังก์ชันหากงานถูกยอมรับแล้ว
        }
      }

      // อัปเดตสถานะผลิตภัณฑ์
      await FirebaseFirestore.instance
          .collection('Product')
          .doc(productId)
          .update({
        'status': 'accepted',
        'riderId': _currentUser!.uid,
        'acceptedAt': FieldValue.serverTimestamp(),
        'productId': productId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // ดึงข้อมูลของผลิตภัณฑ์
      var productData = productSnapshot.data() as Map<String, dynamic>?;

      setState(() {
        _hasActiveOrder = true;
      });
      await _fetchProducts();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Order accepted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Colors.white,
            onPressed: () {
              // ฟังก์ชันที่ต้องการให้ทำเมื่อกดปุ่ม
            },
          ),
        ),
      );
    } catch (e) {
      log('Error accepting order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Failed to accept order. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: () {
              // ฟังก์ชันที่ต้องการให้ทำเมื่อกดปุ่ม เช่น เรียกฟังก์ชัน retry
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      appBar: _buildAppBar(),
      body: _selectedIndex == 0
          ? RefreshIndicator(
              onRefresh: _fetchProducts,
              child:
                  _buildOrderList(), // นี่คือการแสดง Order list เมื่อเลือก "Home"
            )
          : _selectedIndex == 1
              ? ProfileRiderPage() // แสดง Profile เมื่อเลือก "Profile"
              : OrderPage(
                  riderId: _currentUser!.uid), // ส่ง riderId ไปยัง OrderPage
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF890E1C),
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            children: [
              Text(
                _username ?? 'Guest',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 15),
              _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(_profileImageUrl!),
                      radius: 30,
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person,
                          color: Color(0xFF890E1C), size: 30),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() {
          _isLoading = true;
        });
        _fetchProducts();
      },
      child: const Icon(Icons.refresh),
      backgroundColor: const Color(0xFFFFC809),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF890E1C),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined, size: 30),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_4, size: 30),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt, size: 30),
          label: 'Order',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.yellowAccent,
      unselectedItemColor: Colors.white,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }

  Widget _buildOrderList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC809)),
        ),
      );
    }
    if (_hasActiveOrder) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'You have an active order.\nPlease complete it before accepting new orders.',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No orders available',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                _fetchProducts();
              },
              child: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC809),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            margin:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 60.0),
            decoration: const BoxDecoration(
              color: Color(0xFFFFC809),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Order List',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product =
                            _products[index].data() as Map<String, dynamic>;
                        return OrderCard(
                          context: context,
                          product: product,
                          productId: _products[index].id,
                          onAccept: () => _acceptOrder(_products[index].id),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget OrderCard({
    required BuildContext context,
    required Map<String, dynamic> product,
    required String productId,
    required Function onAccept,
  }) {
    RecipientLocation location = RecipientLocation.fromMap(
        product['recipientLocation'] as Map<String, dynamic>);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF890E1C),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.network(
                product['imageUrl'] ?? '',
                width: 90,
                height: 90,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sender: ${product['senderName'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Recipient: ${product['recipientName'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => onAccept(),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFFFC809),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Accept', style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) =>
                    _productDetailDialog(context, product, onAccept),
              );
            },
            child: const Text(
              'Click for detail',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 17, 0),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productDetailDialog(
    BuildContext context,
    Map<String, dynamic> product,
    Function onAccept,
  ) {
    RecipientLocation location = RecipientLocation.fromMap(
        product['recipientLocation'] as Map<String, dynamic>);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 600,
        height: 600,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF890E1C),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 10),
            Center(
              child: Image.network(
                product['imageUrl'] ?? '',
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    Image.asset('assets/images/red_shirt.png', height: 150),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Product Details:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Details: ${product['productDetails'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Sender: ${product['senderName'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Recipient: ${product['recipientName'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Recipient\'s phone: ${product['recipientPhone'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Address: ${location.address}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              'Latitude: ${location.latitude}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Longitude: ${location.longitude}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  onAccept();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFFFC809),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Accept Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
