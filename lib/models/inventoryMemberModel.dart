import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<InventoryMember> postModelFromJson(String str) => List<InventoryMember>.from(
    json.decode(str).map((x) => InventoryMember.fromJson(x)));

String postModelToJson(List<InventoryMember> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class InventoryMember {
  InventoryMember({
    required this.id,
    required this.name,
    required this.joined_on,
    required this.inventory_id,
    required this.member_id,
   
  });
  String id;
  String name;
  Timestamp joined_on;  
  String inventory_id;
  String member_id;
 

  factory InventoryMember.fromJson(Map<String, dynamic> json) => InventoryMember(
        id: json["id"],
        name: json["name"],
        joined_on: json["joined_on"],
        inventory_id: json["inventory_id"],
        member_id: json["member_id"],       
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "joined_on": joined_on,
        "inventory_id": inventory_id,
        "member_id": member_id,        
      };

  factory InventoryMember.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return InventoryMember(
      id: document.id,
      name: data["name"],
      joined_on: data["joined_on"],
      inventory_id: data["inventory_id"],
      member_id: data["member_id"],    
    );
  }
}
