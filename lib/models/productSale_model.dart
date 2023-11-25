import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<ProductSaleModel> postModelFromJson(String str) =>
    List<ProductSaleModel>.from(
        json.decode(str).map((x) => ProductSaleModel.fromJson(x)));

String postModelToJson(List<ProductSaleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductSaleModel {
  ProductSaleModel(
      {required this.id,
      required this.purchased_at,
      required this.selling_price,
      required this.quantity,
      required this.title,
      required this.profit,
      required this.purchase_total,
      required this.sold_quantity,
      required this.total});
  String id;

  String title;

  int purchased_at;
  int selling_price;
  int quantity;
  int sold_quantity;
  int total;
  int purchase_total;
  int profit;

  factory ProductSaleModel.fromJson(Map<String, dynamic> json) =>
      ProductSaleModel(
        id: json["id"],
        title: json["title"],
        purchased_at: json["purchased_at"],
        quantity: json["quantity"],
        selling_price: json['selling_price'],
        profit: json['profit'],
        purchase_total: json['purchase_total'],
        sold_quantity: json['sold_quantity'],
        total: json['total'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "purchased_at": purchased_at,
        "quantity": quantity,
        "selling_price": selling_price,
        "profit": profit,
        "purchase_total": purchase_total,
        "sold_quantity": sold_quantity,
        "total": total,
      };

  factory ProductSaleModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ProductSaleModel(
      id: document.id,
      title: data["title"],
      purchased_at: data["purchased_at"],
      quantity: data["quantity"],
      selling_price: data['selling_price'],
      profit: data['profit'],
      purchase_total: data['purchase_total'],
      sold_quantity: data['sold_quantity'],
      total: data['total'],
    );
  }
}
