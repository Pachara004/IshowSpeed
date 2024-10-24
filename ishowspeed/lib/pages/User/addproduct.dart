import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:location/location.dart';

class AddProductPage extends StatefulWidget {
  final String senderName;

  const AddProductPage({Key? key, required this.senderName}) : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  String? _productName, _productDetails, _recipientName, _recipientPhone;
  String? _imageUrl;
  XFile? _imageFile;
  LatLng? _recipientLocation;
  LatLng? _senderLocation;
  List<Map<String, String>> _searchResults = [];

  final ValueNotifier<LatLng?> selectedLocationNotifier =
      ValueNotifier<LatLng?>(null);
  final ValueNotifier<bool> isMapLoaded = ValueNotifier<bool>(false);
  final ValueNotifier<LocationData?> currentLocationNotifier =
      ValueNotifier<LocationData?>(null);

  final TextEditingController _recipientPhoneController =
      TextEditingController();
  final TextEditingController _recipientNameController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    _fetchAndSetSenderLocation();
  }

  Future<void> _showImageSourceDialog() {
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

  Future<void> _fetchAndSetSenderLocation() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(user.uid)
            .get();

        Map<String, dynamic>? gpsData = userDoc.data()?['gps']?['map'];
        if (gpsData != null) {
          setState(() {
            _senderLocation = LatLng(
              gpsData['latitude'],
              gpsData['longitude'],
            );
          });
        } else {
          // If no stored location, get current location
          Location location = Location();
          LocationData locationData = await location.getLocation();
          setState(() {
            _senderLocation = LatLng(
              locationData.latitude!,
              locationData.longitude!,
            );
          });
        }
      }
    } catch (e) {
      log('Failed to fetch sender location: $e');
    }
  }

  Future<void> _fetchRecipientLocation(String phoneNumber) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var recipientData = querySnapshot.docs.first.data();
        log(
            'Recipient data: $recipientData'); // ดูข้อมูลที่ได้รับจาก Firestore

        var recipientLocation = recipientData['gps']['map'];
        log(
            'Recipient location: $recipientLocation'); // ตรวจสอบโครงสร้าง location

        setState(() {
          _recipientLocation = LatLng(
            recipientLocation['latitude'],
            recipientLocation['longitude'],
          );
          _recipientName = recipientData['username'];
          _recipientPhone = phoneNumber;
        });

        // อัพเดทตำแหน่งที่เลือกในแผนที่
        selectedLocationNotifier.value = _recipientLocation;

        // เพิ่มการอัพเดท MapController เพื่อเลื่อนไปยังตำแหน่งของผู้รับ
        if (isMapLoaded.value) {
          MapController mapController = MapController();
          mapController.move(_recipientLocation!, 15.0);
        }

        // แสดง SnackBar เพื่อยืนยันการเลือกผู้รับ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Selected recipient: $_recipientName ($_recipientPhone)'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        log('No recipient found'); // กรณีไม่พบผู้รับ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipient not found'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      log('Error fetching recipient location: $e'); // พิมพ์ error ที่เกิดขึ้น
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch recipient location'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField(String label, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? '$label is required' : null,
        onSaved: (value) => onSaved(value!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD PRODUCT'),
        centerTitle: true,
        backgroundColor: const Color(0xFF890E1C),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
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
                  // Image Selection Section
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: IconButton(
                      icon: const Icon(Icons.add_a_photo,
                          color: Color(0xFF890E1C), size: 30),
                      onPressed: _showImageSourceDialog,
                    ),
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

                  // Map Section
                  const SizedBox(height: 16),
                  const Text('Select delivery location:',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  SizedBox(
                    height: 200,
                    child: _buildMap(),
                  ),

                  // Location Display
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

                  // Form Fields
                  const SizedBox(height: 16),
                  _buildTextField(
                      'Product Name', (value) => _productName = value),
                  _buildTextField(
                      'Product details', (value) => _productDetails = value),
                  _buildRecipientSection(),

                  // Submit Button
                  const SizedBox(height: 16),
                  ElevatedButton(
                    child: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: const Color(0xFFFFC809),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return FutureBuilder<void>(
      future: _fetchCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            currentLocationNotifier.value != null) {
          LatLng currentLocation = LatLng(
            currentLocationNotifier.value!.latitude!,
            currentLocationNotifier.value!.longitude!,
          );

          return ValueListenableBuilder<LatLng?>(
            valueListenable: selectedLocationNotifier,
            builder: (context, selectedLocation, _) {
              return FlutterMap(
                options: MapOptions(
                  initialCenter: _recipientLocation ?? currentLocation,
                  initialZoom: 15.0,
                  onTap: (_, point) {
                    selectedLocationNotifier.value = point;
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
                    markers: _buildMarkers(currentLocation, selectedLocation),
                  ),
                ],
              );
            },
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  List<Marker> _buildMarkers(LatLng currentLocation, LatLng? selectedLocation) {
    List<Marker> markers = [
      // แสดงตำแหน่งปัจจุบัน
      Marker(
        point: currentLocation,
        child: const Icon(Icons.place, color: Colors.blue, size: 40),
      ),
    ];
    // แสดงตำแหน่งผู้รับ ถ้ามี
    if (_recipientLocation != null) {
      markers.add(
        Marker(
          point: _recipientLocation!,
          child: const Icon(Icons.person_pin_circle,
              color: Colors.green, size: 40),
        ),
      );
    }
    // แสดงตำแหน่งที่เลือก ถ้าไม่ใช่ตำแหน่งเดียวกับผู้รับ
    if (selectedLocation != null &&
        (_recipientLocation == null ||
            selectedLocation.latitude != _recipientLocation!.latitude ||
            selectedLocation.longitude != _recipientLocation!.longitude)) {
      markers.add(
        Marker(
          point: selectedLocation,
          child: const Icon(Icons.place, color: Colors.red, size: 40),
        ),
      );
    }

    return markers;
  }

  TextEditingController _phoneController = TextEditingController();
  void _handlePhoneSelection(String selectedPhoneNumber) {
    setState(() {
      _phoneController.text = selectedPhoneNumber; // อัปเดตค่าหมายเลขที่เลือก
      _recipientPhone = selectedPhoneNumber;
      // อัปเดตฟิลด์อื่นๆ ที่จำเป็น เช่น ชื่อผู้รับ
    });
  }

  Widget _buildRecipientSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Search Phone Number',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.phone),
                ),
                onChanged: _handlePhoneSearch,
                // validator: (value) =>
                //     value!.isEmpty ? 'Phone number is required' : null,
                // onSaved: (value) => _recipientPhone = value,
              ),
              if (_searchResults.isNotEmpty) _buildSearchResults(),

              const SizedBox(height: 8),
              // แสดงข้อมูลผู้รับที่เลือก
              if (_recipientName != null && _recipientPhone != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipient Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Name: $_recipientName'),
                      Text('Phone: $_recipientPhone'),
                      if (_recipientLocation != null)
                        Text(
                          'Location: ${_recipientLocation!.latitude.toStringAsFixed(4)}, '
                          '${_recipientLocation!.longitude.toStringAsFixed(4)}',
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Container(
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
            title: Text(_searchResults[index]['phone']!),
            subtitle: Text(_searchResults[index]['username']!),
            onTap: () => _handleRecipientSelection(index),
          );
        },
      ),
    );
  }

  Future<void> _handlePhoneSearch(String value) async {
    if (value.length >= 3) {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isGreaterThanOrEqualTo: value)
          .where('phone', isLessThanOrEqualTo: value + '\uf8ff')
          .get();

      String? currentUserPhone = await _getCurrentUserPhone();

      setState(() {
        _searchResults = querySnapshot.docs
            .where((doc) => doc.data()['phone'] != currentUserPhone)
            .map((doc) => {
                  'phone': doc['phone'] as String,
                  'username': doc['username'] as String,
                })
            .toList();
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _handleRecipientSelection(int index) {
    setState(() {
      _recipientPhone = _searchResults[index]['phone'];
      _recipientName = _searchResults[index]['username'];
      _recipientPhoneController.text = _recipientPhone!;
      _recipientNameController.text = _recipientName!;
      _fetchRecipientLocation(_recipientPhone!);
      _searchResults = [];
    });
    _fetchRecipientLocation(_recipientPhone!);
  }

  Future<String?> _getCurrentUserPhone() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();
      return userDoc.data()?['phone'];
    }
    return null;
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      Location location = Location();
      LocationData locationData = await location.getLocation();
      currentLocationNotifier.value = locationData;
    } catch (e) {
      print("Failed to fetch current location: $e");
    }
  }

  Future<void> _handleSubmit() async {
    if (_imageFile == null) {
      // Show error dialog if no image is selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color(0xFF890E1C),
            title: const Text(
              'กรุณาเพิ่มรูปภาพ',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'คุณต้องเพิ่มรูปภาพสินค้าก่อนดำเนินการต่อ',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'ตกลง',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return; // Stop execution if no image
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Dialog(
              backgroundColor: Colors.transparent,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC809),
                ),
              ),
            );
          },
        );

        User? user = FirebaseAuth.instance.currentUser;
        String? userId = user?.uid;
        await _uploadImage();

        if (_imageUrl == null) {
          // Hide loading dialog
          Navigator.of(context).pop();
          // Show error if image upload failed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF890E1C),
                title: const Text(
                  'Something went wrong',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Can not upload please try agian',
                  style: TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
          return; // Stop execution if image upload failed
        }

        final selectedLocation = selectedLocationNotifier.value ??
            const LatLng(16.2469, 103.2496); // MSU default location

        Map<String, dynamic> productData = {
          'senderName': widget.senderName,
          'productName': _productName,
          'productDetails': _productDetails,
          'recipientName': _recipientName,
          'recipientPhone': _recipientPhone,
          'imageUrl': _imageUrl,
          'userId': userId,
          'senderLocation': _senderLocation != null
              ? {
                  'latitude': _senderLocation!.latitude,
                  'longitude': _senderLocation!.longitude,
                  'formattedLocation':
                      '${_senderLocation!.latitude.toStringAsFixed(4)}, ${_senderLocation!.longitude.toStringAsFixed(4)}'
                }
              : null,
          'recipientLocation': {
            'latitude': selectedLocation.latitude,
            'longitude': selectedLocation.longitude,
            'formattedLocation':
                '${selectedLocation.latitude.toStringAsFixed(4)}, ${selectedLocation.longitude.toStringAsFixed(4)}'
          },
          'status': 'waiting',
          'timestamp': FieldValue.serverTimestamp(), // Add timestamp
        };

        await FirebaseFirestore.instance.collection('Product').add(productData);

        // Hide loading dialog
        Navigator.of(context).pop();
        // Hide add product dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add product success'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Hide loading dialog if showing
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Show error dialog
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: const Color(0xFF890E1C),
                title: const Text(
                  'something went wrong',
                  style: TextStyle(color: Colors.white),
                ),
                content: Text(
                  'Can not add product: ${e.toString()}',
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  TextButton(
                    child: const Text(
                      'OK',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }
}

// Helper class to show the dialog
class AddProductDialogHelper {
  static void show(BuildContext context, String senderName) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AddProductPage(senderName: senderName),
    );
  }
}
