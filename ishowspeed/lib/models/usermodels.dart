// To parse this JSON data, do
//
//     final usermodels = usermodelsFromJson(jsonString);

import 'dart:convert';

Usermodels usermodelsFromJson(String str) => Usermodels.fromJson(json.decode(str));

String usermodelsToJson(Usermodels data) => json.encode(data.toJson());

class Usermodels {
    String address;
    String email;
    String password;
    String phone;
    String profileImage;
    String userType;
    String username;
    String vehicle;

    Usermodels({
        required this.address,
        required this.email,
        required this.password,
        required this.phone,
        required this.profileImage,
        required this.userType,
        required this.username,
        required this.vehicle,
    });

    factory Usermodels.fromJson(Map<String, dynamic> json) => Usermodels(
        address: json["address"],
        email: json["email"],
        password: json["password"],
        phone: json["phone"],
        profileImage: json["profileImage"],
        userType: json["userType"],
        username: json["username"],
        vehicle: json["vehicle"],
    );

    Map<String, dynamic> toJson() => {
        "address": address,
        "email": email,
        "password": password,
        "phone": phone,
        "profileImage": profileImage,
        "userType": userType,
        "username": username,
        "vehicle": vehicle,
    };
}
