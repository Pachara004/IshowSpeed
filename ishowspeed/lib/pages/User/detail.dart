import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ProductDetailDialog extends StatelessWidget {
  final String imageUrl;
  final String details;
  final String sender;
  final String name;
  final String recipient;
  final String recipientPhone;
  final double? recipientLocationLat;
  final double? recipientLocationLng;

  const ProductDetailDialog({
    super.key,
    required this.imageUrl,
    required this.details,
    required this.sender,
    required this.name,
    required this.recipient,
    required this.recipientPhone,
    required this.recipientLocationLat,
    required this.recipientLocationLng,
  });
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, // เกือบชิดขอบจอ
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF890E1C),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9, // เกือบเต็มจอ
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        imageUrl,
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (recipientLocationLat != null && recipientLocationLng != null)
                Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width * 0.9, // เกือบเต็มจอ
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                            recipientLocationLat!, recipientLocationLng!),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                  recipientLocationLat!, recipientLocationLng!),
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
                ),
              const SizedBox(height: 20),
              _buildInfoSection(
                'Sender name',
                sender,
                Icons.person,
                const Color(0xFFFFD700),
              ),
              const SizedBox(height: 16),
              // ส่วนการเรียกใช้ _buildInfoSection
              _buildInfoSection(
                'Product Name',
                name,
                Icons.inventory_2, // เปลี่ยนเป็นไอคอนสินค้า
                const Color(0xFFFFD700),
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Product Details',
                details,
                Icons.description, // เปลี่ยนเป็นไอคอนรายละเอียดสินค้า
                const Color(0xFFFFD700),
              ),

              const SizedBox(height: 16),
              _buildInfoSection(
                'Recipient Name',
                recipient,
                Icons.person,
                const Color(0xFFFFD700),
              ),
              const SizedBox(height: 16),
              _buildInfoSection(
                'Recipient Phone',
                recipientPhone,
                Icons.phone,
                const Color(0xFFFFD700),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

// ส่วนของ _buildInfoSection
  Widget _buildInfoSection(
    String title,
    String content,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700).withOpacity(0.1), // สีสดใสขึ้น
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFFD700), // สีไอคอนสดใสขึ้น
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold, // ทำให้ข้อความเข้มขึ้น
                  color: Colors
                      .white, // เปลี่ยนสีตัวอักษรเป็นสีขาวเพื่อให้อ่านง่าย
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70, // ปรับสีของเนื้อหาให้อ่านง่ายขึ้น
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
