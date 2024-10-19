import 'package:cloud_firestore/cloud_firestore.dart';

enum ShipmentStatus {
  pending,
  inTransit,
  delivered
}

class ShipmentModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String productName;
  final String productDetails;
  final int numberOfProducts;
  final String imageUrl;
  final String shippingAddress;
  final double latitude;
  final double longitude;
  final ShipmentStatus status;
  final DateTime createdAt;

  ShipmentModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.productName,
    required this.productDetails,
    required this.numberOfProducts,
    required this.imageUrl,
    required this.shippingAddress,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
  });

  factory ShipmentModel.fromMap(Map<String, dynamic> map) {
    return ShipmentModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      productName: map['productName'] ?? '',
      productDetails: map['productDetails'] ?? '',
      numberOfProducts: map['numberOfProducts'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      shippingAddress: map['shippingAddress'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      status: ShipmentStatus.values[map['status'] ?? 0],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}