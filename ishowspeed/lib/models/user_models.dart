// To parse this JSON data, do
//
//     final Usermodel = UsermodelFromJson(jsonString);

import 'dart:convert';

Usermodel UsermodelFromJson(String str) => Usermodel.fromJson(json.decode(str));

String UsermodelToJson(Usermodel data) => json.encode(data.toJson());

class Usermodel {
    String address;
    String email;
    String gps;
    String password;
    String phone;
    String profileImage;
    String userType;
    String username;
    String vehicle;

    Usermodel({
        required this.address,
        required this.email,
        required this.gps,
        required this.password,
        required this.phone,
        required this.profileImage,
        required this.userType,
        required this.username,
        required this.vehicle,
    });

    factory Usermodel.fromJson(Map<String, dynamic> json) => Usermodel(
        address: json["address"],
        email: json["email"],
        gps: json["gps"],
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
        "gps": gps,
        "password": password,
        "phone": phone,
        "profileImage": profileImage,
        "userType": userType,
        "username": username,
        "vehicle": vehicle,
    };
}
