import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<InventoryModel> postModelFromJson(String str) => List<InventoryModel>.from(
    json.decode(str).map((x) => InventoryModel.fromJson(x)));

String postModelToJson(List<InventoryModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InventoryModel {
  InventoryModel({
    required this.id,
    required this.created_on,
    required this.invite_code,
    required this.owner_id,
    required this.title,
  });
  String id;
  String title;
  Timestamp created_on;
  String invite_code;
  String owner_id;

  factory InventoryModel.fromJson(Map<String, dynamic> json) => InventoryModel(
      id: json["id"],
      created_on: json["created_on"],
      invite_code: json["invite_code"],
      owner_id: json["owner_id"],
      title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_on": created_on,
        "invite_code": invite_code,
        "owner_id": owner_id,
        "title": title,        
      };

  factory InventoryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return InventoryModel(
      id: document.id,
      created_on: data["created_on"],
      invite_code: data["invite_code"],
      owner_id: data["owner_id"],      
      title: data["title"],
    );
  }
}
