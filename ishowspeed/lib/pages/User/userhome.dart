import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ishowspeed/pages/User/history.dart';
import 'package:ishowspeed/pages/User/profile.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class UserHomePage extends StatefulWidget {
  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  User? _currentUser;
  String? _profileImageUrl;
  String? _username;
  String? _phone;
  List<User> _users = []; // รายชื่อผู้ใช้ทั้งหมด
  User? _selectedUser; // ผู้ใช้ที่เลือก

  @override
  void initState() {
    super.initState();

    // ดึงข้อมูลผู้ใช้จาก FirebaseAuth
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
          _profileImageUrl = userDoc.data()?['profileImage'] ??
              ''; // ถ้าไม่มี URL รูปจะเป็นค่าว่าง
          _username = userDoc.data()?['username'] ??
              'Guest'; // ถ้าไม่มี username จะแสดง Guest
          _phone = userDoc.data()?['phone'];
        });

        // Log ข้อมูลโปรไฟล์ (หากมี)
        log(_phone.toString());
        log("Profile Image URL: $_profileImageUrl");
        log("Username: $_username");
      }
    });
  }

  void _fetchUserData() async {
    if (_currentUser != null) {
      // ดึงรูปโปรไฟล์จาก Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      setState(() {
        _profileImageUrl = userDoc.data()?['profileImage'] ??
            ''; // ถ้าไม่มี URL รูปจะเป็นค่าว่าง
        _username = userDoc.data()?['username'] ??
            'Guest'; // ถ้าไม่มี username จะแสดง Guest
      });

      // Log ข้อมูลโปรไฟล์ (หากมี)
      log("Profile Image URL: $_profileImageUrl");
      log("Username: $_username");
    }
  }

  final List<Widget> _pages = [
    UserDashboard(),
    ProfilePage(),
    UserHistoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF890E1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF890E1C),
        automaticallyImplyLeading: false,
        actions: [
          // ใช้ Row เพื่อแสดงรูปโปรไฟล์และชื่อผู้ใช้
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  _username ??
                      'Guest', // ถ้า _username เป็น null ให้แสดง 'Guest'
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16, // ปรับขนาดฟอนต์ตามต้องการ
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 15),
                _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(
                            _profileImageUrl!), // ใช้เครื่องหมาย ! เพื่อบอกว่าไม่เป็น null แน่นอน
                        radius: 30, // ปรับขนาดรูปโปรไฟล์
                      )
                    : const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 30, // ปรับขนาดเมื่อไม่มีรูป
                        child: Icon(Icons.person,
                            color: Color(0xFF890E1C), size: 30),
                      ),
                const SizedBox(width: 8), // เว้นช่องว่างระหว่างรูปและชื่อ
              ],
            ),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF890E1C),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 30, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_4, size: 30, color: Colors.white),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 30, color: Colors.white),
            label: 'Shipping History',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellowAccent, // สีที่เด่นขึ้นเมื่อเลือก
        unselectedItemColor: Colors.grey[400], // สีที่ดูอ่อนลงเมื่อไม่ได้เลือก
        selectedIconTheme: const IconThemeData(
            size: 35, color: Colors.yellowAccent), // ขนาดและสีไอคอนเมื่อเลือก
        unselectedIconTheme: IconThemeData(
            size: 30,
            color: Colors.grey[400]), // ขนาดและสีไอคอนเมื่อไม่ได้เลือก
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, // น้ำหนักตัวอักษรหนาขึ้นเมื่อเลือก
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal, // น้ำหนักตัวอักษรเบาลงเมื่อไม่ได้เลือก
          fontSize: 12,
        ),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _fetchUserData();
          });
        },
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  User? _currentUser;
  String? _profileImageUrl;
  String? _username;
  String? _phone;
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    // ดึงข้อมูลผู้ใช้จาก FirebaseAuth
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        setState(() {
          _currentUser = user;
        });

        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        setState(() {
          _profileImageUrl = userDoc.data()?['profileImage'] ?? '';
          _username = userDoc.data()?['username'] ?? 'Guest';
          _phone = userDoc.data()?['phone'];
        });
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(80.0), // ปรับขนาดความสูงตามที่คุณต้องการ
        child: AppBar(
          backgroundColor: const Color(0xFF890E1C),
          title: const Text(''),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor:
                const Color(0xFFFFC809), // สีของแถบที่เลือก (สีเหลือง)
            indicatorWeight: 4.0, // ความหนาของแถบที่เลือก
            labelColor: Colors.white, // สีตัวอักษรของแท็บที่เลือก
            unselectedLabelColor:
                Colors.white70, // สีตัวอักษรของแท็บที่ไม่ได้เลือก
            labelStyle: const TextStyle(
              fontSize: 18, // ขนาดตัวอักษรของแท็บที่เลือก
              fontWeight: FontWeight.bold, // ทำให้ตัวอักษรของแท็บที่เลือกหนา
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 16, // ขนาดตัวอักษรของแท็บที่ไม่ได้เลือก
            ),
            tabs: const [
              Tab(
                text: 'Sender',
                iconMargin: EdgeInsets.only(
                    bottom: 6), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
              ),
              Tab(
                text: 'Receiver',
                iconMargin: EdgeInsets.only(
                    bottom: 6), // เพิ่มระยะห่างระหว่างไอคอนกับข้อความ
              ),
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
    );
  }

  Widget _buildSenderTab() {
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
                      'Products you send:',
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
                        .where("status", isEqualTo: "waiting")
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
                                data['Sender Name'] ?? _username ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'],
                            details: data['productDetails'] ??
                                'No details available.',
                            recipientPhone: data['recipientPhone'],
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _showAddProductDialog(context, _username ?? 'Unknown');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAB000D),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Add Product",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
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
                      'Products you must receive:',
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
                        .where("recipientPhone", isEqualTo: _phone)
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
                                data['Sender Name'] ?? _username ?? 'Unknown',
                            recipient: data['recipientName'] ?? 'Unknown',
                            imageUrl: data['imageUrl'],
                            details: data['productDetails'] ??
                                'No details available.',
                            recipientPhone: data['recipientPhone'],
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
}

// Method for showing the add product dialog
void _showAddProductDialog(BuildContext context, String senderName) {
  showDialog(
    context: context,
    builder: (BuildContext context) =>
        _buildAddProductDialog(context, senderName),
  );
}

// Widget method for building the add product dialog
Widget _buildAddProductDialog(BuildContext context, String senderName) {
  final _formKey = GlobalKey<FormState>();
  String? _productDetails, _recipientName, _recipientPhone;
  String? _imageUrl; // สำหรับเก็บ URL ของภาพ

  // ตัวแปรสำหรับเลือกภาพ
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile; // สำหรับเก็บภาพที่เลือก

  // ฟังก์ชันสำหรับเลือกวิธีการรับภาพ
  Future<void> _showImageSourceDialog(
      BuildContext context, StateSetter setState) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF890E1C),
          title:
              const Text('เลือกรูปภาพ', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: const Text('เลือกจากแกลลอรี่',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() => _imageFile = image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: const Text('ถ่ายรูป',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1800,
                    maxHeight: 1800,
                  );
                  if (image != null) {
                    setState(() => _imageFile = image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      try {
        final storageRef =
            FirebaseStorage.instance.ref('product_images/${_imageFile!.name}');
        await storageRef.putFile(File(_imageFile!.path));
        _imageUrl = await storageRef.getDownloadURL();
        log('Image uploaded: $_imageUrl');
      } catch (e) {
        log('Failed to upload image: $e');
      }
    }
  }

  List<Map<String, String>> _searchResults = [];
  final ValueNotifier<LatLng?> selectedLocationNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<bool> isMapLoaded = ValueNotifier<bool>(false);
  final ValueNotifier<LocationData?> currentLocationNotifier =
      ValueNotifier<LocationData?>(null);
  final LatLng msuLocation = const LatLng(16.2469, 103.2496);
  final TextEditingController _recipientPhoneController =
      TextEditingController();
  final TextEditingController _recipientNameController =
      TextEditingController();
  return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
    LatLng _selectedLocation = const LatLng(16.2469, 103.2496);
    var msuLocation = const LatLng(16.2469, 103.2496);

    void _handleTap(
        TapPosition tapPosition, LatLng point, StateSetter setState) {
      print("Tapped at: $point");
      setState(() {
        _selectedLocation = point;
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF890E1C),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 30,
                  child: IconButton(
                    icon: const Icon(Icons.add_a_photo,
                        color: Color(0xFF890E1C), size: 30),
                    onPressed: () => _showImageSourceDialog(context, setState),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add a product photo',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (_imageFile != null) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              child: Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 300,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_imageFile!.path),
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const Text('Select delivery location:',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FutureBuilder<void>(
                        future:
                            Future.delayed(const Duration(milliseconds: 100)),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ValueListenableBuilder<LatLng?>(
                              valueListenable: selectedLocationNotifier,
                              builder: (context, selectedLocation, _) {
                                return FlutterMap(
                                  options: MapOptions(
                                    initialCenter: msuLocation,
                                    initialZoom: 15.0,
                                    onTap: (_, point) {
                                      selectedLocationNotifier.value =
                                          point; // อัปเดต selectedLocationNotifier
                                      setState(() {
                                        _selectedLocation =
                                            point; // อัปเดต _selectedLocation
                                      });
                                    },
                                    onMapReady: () {
                                      isMapLoaded.value = true;
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
                                        if (selectedLocation != null)
                                          Marker(
                                            point: selectedLocation,
                                            child: const Icon(
                                              Icons.place,
                                              color: Colors.blue,
                                              size: 40,
                                            ),
                                          ),
                                        if (selectedLocation == null)
                                          Marker(
                                            point: msuLocation,
                                            child: const Icon(
                                              Icons.location_on,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                          return Container(
                            color: Colors.white,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'กำลังโหลดแผนที่...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<LatLng?>(
                  valueListenable: selectedLocationNotifier,
                  builder: (context, selectedLocation, _) {
                    return Text(
                      selectedLocation != null
                          ? 'Selected Location: ${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}'
                          : 'Selected Location: Not selected',
                      style: const TextStyle(color: Colors.white),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                    'Product details', (value) => _productDetails = value),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Search Phone Number',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.phone),
                            ),
                            onChanged: (value) async {
                              if (value.length >= 3) {
                                var querySnapshot = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .where('phone',
                                        isGreaterThanOrEqualTo: value)
                                    .where('phone',
                                        isLessThanOrEqualTo: value + '\uf8ff')
                                    .get();

                                setState(() {
                                  _searchResults =
                                      querySnapshot.docs.map((doc) {
                                    return {
                                      'phone': doc['phone'] as String,
                                      'username': doc['username'] as String,
                                    };
                                  }).toList();
                                });
                              } else {
                                setState(() {
                                  _searchResults = [];
                                });
                              }
                            },
                            validator: (value) => value!.isEmpty
                                ? 'Phone number is required'
                                : null,
                            onSaved: (value) => _recipientPhone = value,
                          ),
                          if (_searchResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              constraints: const BoxConstraints(maxHeight: 150),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title:
                                        Text(_searchResults[index]['phone']!),
                                    subtitle: Text(
                                        _searchResults[index]['username']!),
                                    onTap: () {
                                      setState(() {
                                        // อัปเดตเบอร์โทรศัพท์และชื่อเมื่อกดเลือกรายชื่อ
                                        _recipientPhone =
                                            _searchResults[index]['phone'];
                                        _recipientName =
                                            _searchResults[index]['username'];
                                        _recipientPhoneController.text =
                                            _recipientPhone!;
                                        _recipientNameController.text =
                                            _recipientName!;
                                        _searchResults = [];
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Recipient Name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              prefixIcon: const Icon(Icons.person),
                            ),
                            enabled: false,
                            controller:
                                TextEditingController(text: _recipientName),
                            validator: (value) => value!.isEmpty
                                ? 'Recipient name is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  child: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFFFC809),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      User? user = FirebaseAuth.instance.currentUser;
                      String? userId = user?.uid;
                      await _uploadImage();

                      final selectedLocation =
                          selectedLocationNotifier.value ?? msuLocation;

                      Map<String, dynamic> productData = {
                        'senderName': senderName,
                        'productDetails': _productDetails,
                        'recipientName': _recipientName,
                        'recipientPhone': _recipientPhone,
                        'imageUrl': _imageUrl,
                        'userId': userId,
                        'recipientLocation': {
                          'latitude': selectedLocation.latitude,
                          'longitude': selectedLocation.longitude,
                          'formattedLocation':
                              '${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}' // เพิ่มค่าพิกัดที่จัดฟอร์แมตแล้ว
                        }, // Save selected location
                        'status': 'waiting', // Set status to waiting
                      };

                      try {
                        await FirebaseFirestore.instance
                            .collection('Product')
                            .add(productData);
                        log('Product added successfully!');
                        Navigator.of(context).pop();
                      } catch (e) {
                        log('Failed to add product: $e');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  });
}

// Method for building a text field
Widget _buildTextField(String label, Function(String?) onSave) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: (value) => value!.isEmpty ? 'This field is required' : null,
      onSaved: onSave,
    ),
  );
}

// Method for product items
Widget ProductItem({
  required BuildContext context, // รับ context
  required String sender,
  required String recipient,
  required String imageUrl,
  required String details,
  required String recipientPhone,
  required Map<String, dynamic> data,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFAB000D),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            imageUrl,
            width: 74,
            height: 80,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(9.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sender: $sender',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  'Detail: $details',
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
              _showProductDetailDialog(
                context, // ส่ง context ให้ฟังก์ชันนี้
                imageUrl: imageUrl,
                details: details,
                sender: sender,
                recipient: recipient,
                recipientPhone: recipientPhone,
                recipientLocationLat: data['recipientLocation']['latitude'],
                recipientLocationLng: data['recipientLocation']['longitude'],
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC809),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Detail'),
          ),
        ),
      ],
    ),
  );
}

// Method for showing the product detail dialog
void _showProductDetailDialog(
  BuildContext context, {
  required String imageUrl,
  required String details,
  required String sender,
  required String recipient,
  required String recipientPhone,
  required double? recipientLocationLat,
  required double? recipientLocationLng,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF890E1C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          // ใช้ SingleChildScrollView เพื่อแก้ปัญหา overflow
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Close'),
                              onPressed: () {
                                Navigator.of(context).pop(); // ปิดกล่องโต้ตอบ
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Image.network(
                    imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (recipientLocationLat != null && recipientLocationLng != null)
                SizedBox(
                  height: 200, // You can adjust the height
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(recipientLocationLat,
                          recipientLocationLng), // Set recipient's location
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
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
              const SizedBox(height: 16),
              Text(
                  'Location: (${recipientLocationLat.toString()}, ${recipientLocationLng.toString()})',
                  style: const TextStyle(color: Colors.white)),
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Sender Name:\n',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20), // ข้อความที่ไม่ใช่ตัวแปร
                    ),
                    TextSpan(
                      text: sender, // ตัวแปร sender
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const TextSpan(text: '\n'), // เว้นบรรทัด

                    const TextSpan(
                      text: 'Product Details:\n',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    TextSpan(
                      text: details, // ตัวแปร details
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const TextSpan(text: '\n'), // เว้นบรรทัด

                    const TextSpan(
                      text: 'Recipient name:\n',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    TextSpan(
                      text: recipient, // ตัวแปร recipient
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const TextSpan(text: '\n'), // เว้นบรรทัด

                    const TextSpan(
                      text: 'Recipient\'s phone number:\n',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    TextSpan(
                      text: recipientPhone, // ตัวแปร recipientPhone
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
