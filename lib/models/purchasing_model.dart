import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<PurchasingModel> postModelFromJson(String str) =>
    List<PurchasingModel>.from(
        json.decode(str).map((x) => PurchasingModel.fromJson(x)));

String postModelToJson(List<PurchasingModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PurchasingModel {
  PurchasingModel(
      {required this.id,
      required this.date,
      required this.spendings,
      required this.quantity,
      required this.recieptUrl,
      required this.labour_cost,
      required this.total_spending,
      required this.user_id});

  String id;
  String recieptUrl;
  String user_id;
  Timestamp date;
  int spendings;
  int quantity;
  int labour_cost;
  int total_spending;

  factory PurchasingModel.fromJson(Map<String, dynamic> json) =>
      PurchasingModel(
        id: json["id"],
        date: json["date"],
        quantity: json["quantity"],
        spendings: json['spendings'],
        total_spending: json['total_spending'],
        recieptUrl: json['recieptUrl'],
        labour_cost: json['labour_cost'],
        user_id: json['user_id'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "date": date,
        "quantity": quantity,
        "total_spending": total_spending,
        "spendings": spendings,
        "recieptUrl": recieptUrl,
        "labour_cost": labour_cost,
        "user_id": user_id
      };

  factory PurchasingModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return PurchasingModel(
        id: document.id,
        date: data["date"],
        quantity: data["quantity"],
        total_spending: data["total_spending"],
        spendings: data['spendings'],
        recieptUrl: data['recieptUrl'],
        labour_cost: data['labour_cost'],
        user_id: data['user_id']);
  }
}
