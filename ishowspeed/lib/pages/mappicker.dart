// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';

// class MapPicker extends StatefulWidget {
//   final Function(LatLng) onLocationSelected;

//   const MapPicker({Key? key, required this.onLocationSelected}) : super(key: key);

//   @override
//   _MapPickerState createState() => _MapPickerState();
// }

// class _MapPickerState extends State<MapPicker> {
//   LatLng _pickedLocation = LatLng(13.736717, 100.523186); // Default location (Bangkok)

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Location'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check),
//             onPressed: () {
//               widget.onLocationSelected(_pickedLocation);
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//       body: FlutterMap(
//         options: MapOptions(
//           center: _pickedLocation, // ตั้งค่า center
//           zoom: 13.0,              // ตั้งค่า zoom
//           onTap: (tapPosition, point) {
//             setState(() {
//               _pickedLocation = point; // อัปเดตตำแหน่งเมื่อคลิกบนแผนที่
//             });
//           },
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: [
//               Marker(
//                 point: _pickedLocation,
//                 builder: (ctx) => const Icon(
//                   Icons.location_on,
//                   color: Colors.red,
//                   size: 40,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
