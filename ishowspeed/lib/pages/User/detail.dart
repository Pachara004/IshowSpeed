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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF890E1C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
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
                              Navigator.of(context).pop();
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
                height: 200,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(recipientLocationLat!, recipientLocationLng!),
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(recipientLocationLat!, recipientLocationLng!),
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

            // ใช้การจัดกลุ่มข้อมูลด้วยฟังก์ชัน
            _buildCenteredInfo('Sender Name', sender),
            _buildCenteredInfo('Product Name', name),
            _buildCenteredInfo('Product Details', details),
            _buildCenteredInfo('Recipient Name', recipient),
            _buildCenteredInfo('Recipient\'s Phone Number', recipientPhone),
          ],
        ),
      ),
    ),
  );
}

Widget _buildCenteredInfo(String title, String content) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12.0), // ระยะห่างระหว่างแต่ละกล่อง
    color: const Color.fromARGB(255, 255, 255, 255),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            color: const Color(0xFF890E1C),
            padding: const EdgeInsets.all(8.0), // เพิ่ม padding ให้กับข้อความ
            child: Text(
              title,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255), // สีข้อความเป็นสีขาว
                fontSize: 18,
                fontWeight: FontWeight.bold, // ทำให้หัวข้อหนาขึ้น
              ),
            ),
          ),
        ),
        Center(
          child: Text(
            content,
            style: const TextStyle(
              color: Color.fromARGB(255, 27, 18, 18),
              fontSize: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

}