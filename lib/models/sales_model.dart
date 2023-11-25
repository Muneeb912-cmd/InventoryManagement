import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<SalesModel> postModelFromJson(String str) =>
    List<SalesModel>.from(json.decode(str).map((x) => SalesModel.fromJson(x)));

String postModelToJson(List<SalesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SalesModel {
  SalesModel(
      {required this.id,
      required this.sale_date,
      required this.buyer,
      required this.profit,
      required this.purchase_total,
      required this.seller,
      required this.sold_quantity,
      required this.seller_id,
      required this.total});
  String id;
  String seller_id;
  Timestamp sale_date;

  int sold_quantity;
  String seller;
  String buyer;
  int total;
  int purchase_total;
  int profit;

  factory SalesModel.fromJson(Map<String, dynamic> json) => SalesModel(
        id: json["id"],
        sale_date: json["sale_date"],
        buyer: json['buyer'],
        profit: json['profit'],
        purchase_total: json['purchase_total'],
        seller: json['seller'],
        sold_quantity: json['sold_quantity'],
        total: json['total'],
        seller_id: json['seller_id'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sale_date": sale_date,
        "buyer": buyer,
        "profit": profit,
        "purchase_total": purchase_total,
        "seller": seller,
        "sold_quantity": sold_quantity,
        "total": total,
        "seller_id": seller_id
      };

  factory SalesModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return SalesModel(
      id: document.id,
      sale_date: data["sale_date"],
      buyer: data['buyer'],
      profit: data['profit'],
      purchase_total: data['purchase_total'],
      seller: data['seller'],
      sold_quantity: data['sold_quantity'],
      total: data['total'],
      seller_id: data['seller_id'],
    );
  }
}
