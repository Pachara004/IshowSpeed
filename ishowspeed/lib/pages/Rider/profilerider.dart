import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ishowspeed/pages/login.dart';
import 'package:path/path.dart';

class ProfileRiderPage extends StatefulWidget {
  @override
  _ProfileRiderPageState createState() => _ProfileRiderPageState();
}

class _ProfileRiderPageState extends State<ProfileRiderPage> {
  User? currentUser;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    checkCurrentUser();
  }

  void checkCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      setState(() {
        currentUser = FirebaseAuth.instance.currentUser;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return LoginPage();
        }

        currentUser = snapshot.data;
        String uid = currentUser!.uid;

        return Scaffold(
          backgroundColor: const Color(0xFF890E1C),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100.0), // ปรับความสูงที่นี่
            child: AppBar(
              title: const Center(
                child: Text(
                  '',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              backgroundColor: const Color(0xFF890E1C),
              automaticallyImplyLeading: false,
              elevation: 0,
            ),
          ),
          body: FutureBuilder<DocumentSnapshot>(
            future:
                FirebaseFirestore.instance.collection('users').doc(uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text('User data not found'));
              }

              var userData = snapshot.data!.data() as Map<String, dynamic>;
              String profileImageUrl = userData['profileImage'] ?? '';

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC809), // สีของ Container
                        borderRadius: BorderRadius.circular(20), // ปรับความโค้งของขอบ
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // จัดข้อความชิดซ้าย
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // จัดข้อความให้อยู่ด้านบนของ Row
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // เมื่อกดที่รูปภาพ จะเปิด Dialog เพื่อแสดงรูปแบบเต็ม
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          width: 300, // กำหนดขนาดของ dialog
                                          height: 300,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: profileImageUrl.isNotEmpty
                                                  ? NetworkImage(profileImageUrl)
                                                  : const AssetImage('assets/images/default_profile.png')
                                                      as ImageProvider,
                                              fit: BoxFit.cover, // ปรับรูปให้ครอบคลุมพื้นที่
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: profileImageUrl.isNotEmpty
                                      ? NetworkImage(profileImageUrl)
                                      : const AssetImage('assets/images/default_profile.png')
                                          as ImageProvider,
                                ),
                              ),
                              const SizedBox( width:25 ), // เพิ่มระยะห่างระหว่างรูปโปรไฟล์กับข้อความ
                              Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // จัดข้อความชิดซ้าย
                                children: [
                                  Text(
                                    userData['username'] ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(
                                      height:
                                          4), // ลดระยะห่างระหว่าง username และ email
                                  Text(
                                    userData['email'] ?? 'N/A',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  10), // เพิ่มระยะห่างระหว่าง Row และ Personal Information
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0.0, left: 16.0, right: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Personal Information',
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextButton(
                                              // onPressed: () {
                                              //   // เชื่อมไปยังหน้า EditProfilePage
                                              //   Navigator.of(context).push(
                                              //     MaterialPageRoute(
                                              //       builder: (context) =>
                                              //           EditProfilePage(),
                                              //     ),
                                              //   );
                                              // },
                                              onPressed: () {
                                                _showEditProfileDialog(context, userData);
                                              },
                                              child: const Text(
                                                'Edit',
                                                style: TextStyle(
                                                  fontSize: 19,
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w800, // เพิ่มจุลภาคที่นี่
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        _buildInfoRow('Full Name',
                                            userData['username'] ?? 'N/A'),
                                        _buildInfoRow('Phone', 
                                            formatPhoneNumber(userData['phone'])),
                                        _buildInfoRow('Email',
                                            userData['email'] ?? 'N/A'),
                                        _buildInfoRow('Vehicle Number',
                                            userData['vehicle'] ?? 'N/A'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                      height: 150), // ย้าย SizedBox ไปที่นี่
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // เพิ่มระยะห่างก่อนปุ่ม

                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Center(
                              // ใช้ Center เพื่อทำให้ปุ่มอยู่ตรงกลาง
                              child: ElevatedButton(
                                onPressed: () => _logout(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 172, 25, 25), // สีปุ่มเป็นสีเหลือง
                                  minimumSize: const Size(
                                      80, 50), // ปรับความกว้างของปุ่ม
                                  shadowColor: Colors.black, // สีเงา
                                  elevation: 15, // ความสูงของเงา
                                ),
                                child: const Text(
                                  'Log out',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromARGB(255, 255, 255, 255), // สีข้อความเป็นสีดำ
                                    fontWeight: FontWeight.w800, // เพิ่มความหนาของฟอนต์เป็น extra bold
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              );
              
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
        ],
      ),
    );
  }
  String formatPhoneNumber(String? phoneNumber) {
  // ตรวจสอบว่าหมายเลขโทรศัพท์ไม่เป็น null และมีความยาว 10 หลัก
  if (phoneNumber != null && phoneNumber.length == 10) {
    return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
  }
  return 'N/A'; // ถ้าไม่ตรงตามเงื่อนไขให้คืนค่า 'N/A'
}

void _showEditProfileDialog(BuildContext context, Map<String, dynamic> userData) {
  TextEditingController usernameController = TextEditingController(text: userData['username']);
  TextEditingController phoneController = TextEditingController(text: userData['phone']);
  TextEditingController emailController = TextEditingController(text: userData['email']);
  TextEditingController vehicleController = TextEditingController(text: userData['vehicle']);

  String? profileImageUrl = userData['profileImage'];

  showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF890E1C), // เปลี่ยนสีพื้นหลังของ AlertDialog
      title: const Center( // ใช้ Center เพื่อจัดตำแหน่งข้อความให้กึ่งกลาง
        child: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white), // เปลี่ยนสีข้อความ
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Center( // ใช้ Center เพื่อจัดตำแหน่งให้กึ่งกลาง
              child: GestureDetector(
                onTap: () => _pickImage(context, (newImageUrl) {
                  setState(() {
                    profileImageUrl = newImageUrl; // อัปเดต profileImageUrl ด้วย URL ใหม่
                  });
                }), // ส่งฟังก์ชัน callback เพื่ออัปเดต profileImageUrl
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: (profileImageUrl != null && profileImageUrl!.isNotEmpty)
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: ' ',
                labelStyle: const TextStyle(color: Colors.black), // เปลี่ยนสีข้อความป้ายเป็นดำ
                filled: true, // ทำให้พื้นหลังเต็ม
                fillColor: Colors.white, // ตั้งค่าสีพื้นหลังเป็นสีขาว
                border: OutlineInputBorder( // กำหนดขอบเขต
                  borderRadius: BorderRadius.circular(15), // มุมมน
                  borderSide: const BorderSide(color: Colors.grey), // สีของขอบ
                ),
                enabledBorder: OutlineInputBorder( // ขอบเมื่อไม่ถูกเลือก
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey), // สีของขอบ
                ),
                focusedBorder: OutlineInputBorder( // ขอบเมื่อถูกเลือก
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF890E1C)), // สีของขอบที่เลือก
                ),
              ),
              style: const TextStyle(color: Colors.black), // เปลี่ยนสีข้อความเป็นดำ
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: ' ',
                labelStyle: const TextStyle(color: Colors.black), // เปลี่ยนสีข้อความป้ายเป็นดำ
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF890E1C)),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: ' ',
                labelStyle: const TextStyle(color: Colors.black), // เปลี่ยนสีข้อความป้ายเป็นดำ
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF890E1C)),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: vehicleController,
              decoration: InputDecoration(
                labelText: ' ',
                labelStyle: const TextStyle(color: Colors.black), // เปลี่ยนสีข้อความป้ายเป็นดำ
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF890E1C)),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.white)), // เปลี่ยนสีข้อความ
        ),
        ElevatedButton(
          onPressed: () async {
            // Update Firestore with new data
            try {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .update({
                  // Add profileImageUrl if it is updated
                  'profileImage': profileImageUrl,
                  'username': usernameController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                  'vehicle': vehicleController.text,
                });

                // Update successful
                Navigator.of(context).pop(); // ปิด Dialog หลังจากอัปเดตสำเร็จ
                setState(() {}); // เรียก setState เพื่อ refresh หน้าจอ
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Profile updated successfully!',
                      style: TextStyle(
                        fontSize: 16, // ปรับขนาดฟอนต์ตามต้องการ
                        fontWeight: FontWeight.bold, // ทำให้ฟอนต์หนาขึ้น
                      ),
                    ),
                    backgroundColor: Colors.green, // เปลี่ยนสีพื้นหลัง
                    duration: const Duration(seconds: 2), // ระยะเวลาแสดง SnackBar
                    action: SnackBarAction(
                      label: 'Undo', // ปุ่มสำหรับการทำงานเพิ่มเติม
                      textColor: Colors.white, // สีข้อความปุ่ม
                      onPressed: () {
                        // การกระทำที่ต้องการเมื่อกดปุ่ม Undo
                      },
                    ),
                    shape: RoundedRectangleBorder( // เปลี่ยนรูปร่างของ SnackBar
                      borderRadius: BorderRadius.circular(8), // ปรับรัศมีมุม
                    ),
                    behavior: SnackBarBehavior.floating, // ให้ SnackBar ลอยอยู่เหนือเนื้อหา
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update profile: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC809), // เปลี่ยนสีพื้นหลังของปุ่ม
          ),
          child: const Text('Save'),
        ),
      ],
    );
  },
);
}
void _pickImage(BuildContext context, Function(String) onImageSelected) async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    // Upload the image to Firebase Storage and get the download URL
    String imageUrl = await uploadImageToFirebase(image.path); // ฟังก์ชันที่คุณจะสร้างเพื่ออัปโหลดรูปภาพ

    setState(() {
      profileImageUrl = imageUrl; // อัปเดต profileImageUrl ด้วย URL ใหม่
    });
  }
}

Future<String> uploadImageToFirebase(String filePath) async {
  File file = File(filePath);
  String fileName = basename(file.path); // ใช้ basename ที่นี่
  Reference storageRef = FirebaseStorage.instance.ref().child('profile_images/$fileName');

  await storageRef.putFile(file);
  return await storageRef.getDownloadURL(); // คืนค่า URL ของภาพที่อัปโหลด
}

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Failed: $e')),
      );
    }
  }
}
