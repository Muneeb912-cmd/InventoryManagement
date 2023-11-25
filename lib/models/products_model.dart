import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<ProductModel> postModelFromJson(String str) => List<ProductModel>.from(
    json.decode(str).map((x) => ProductModel.fromJson(x)));

String postModelToJson(List<ProductModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProductModel {
  ProductModel(
      {required this.id,
      required this.date_added,
      required this.date_updated,
      required this.imageUrl,
      required this.purchased_at,
      required this.selling_price,
      required this.quantity,
      required this.title,
      required this.product_category});
  String id;
  String title;
  Timestamp date_added;
  Timestamp date_updated;
  String imageUrl;
  int purchased_at;
  String product_category;
  int selling_price;
  int quantity;

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
      id: json["id"],
      date_added: json["date_added"],
      date_updated: json["date_updated"],
      imageUrl: json["imageUrl"],
      title: json["title"],
      purchased_at: json["purchased_at"],
      quantity: json["quantity"],
      selling_price: json['selling_price'],
      product_category: json['product_category']);

  Map<String, dynamic> toJson() => {
        "id": id,
        "date_added": date_added,
        "date_updated": date_updated,
        "imageUrl": imageUrl,
        "title": title,
        "purchased_at": purchased_at,
        "quantity": quantity,
        "selling_price": selling_price,
        "product_category": product_category
      };

  factory ProductModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return ProductModel(
        id: document.id,
        date_added: data["date_added"],
        date_updated: data["date_updated"],
        imageUrl: data["imageUrl"],
        title: data["title"],
        purchased_at: data["purchased_at"],
        quantity: data["quantity"],
        selling_price: data['selling_price'],
        product_category: data['product_category']);
  }
}
