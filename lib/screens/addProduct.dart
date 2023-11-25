import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/products_model.dart';

class AddProduct extends StatefulWidget {
  final String inventoryID;
  AddProduct({Key? key, required this.inventoryID}) : super(key: key);

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  String title = '';
  int quantity = 0;
  int purchased_at = 0;
  int selling_price = 0;
  String category = '';
  String? image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.getImage(source: source);

    if (pickedFile != null) {
      setState(() {
        image = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white60,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Add Product'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.camera),
                  child: Text('Take Photo'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _getImage(ImageSource.gallery),
                  child: Text('Select Photo'),
                ),
                SizedBox(height: 16),
                if (image != null) ...[
                  Image.file(
                    File(image!),
                    height: 250,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                ],
                TextField(
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Product Title'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      category = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Product Category'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      quantity = int.tryParse(value) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      purchased_at = int.tryParse(value) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: 'Purchased price (Rs.)'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      selling_price = int.tryParse(value) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Selling price (Rs.)'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Timestamp date_added = Timestamp.now();
                    Timestamp date_updated = Timestamp.now();
                    ProductModel pm = ProductModel(
                        id: 'id',
                        date_added: date_added,
                        date_updated: date_updated,
                        imageUrl: image!,
                        purchased_at: purchased_at,
                        quantity: quantity,
                        title: title,
                        selling_price: selling_price,
                        product_category: category);
                    try {
                      await remort_services()
                          .createProduct(pm, widget.inventoryID, pm.imageUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Product added Successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('An error might have occured! $e'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Text('Add Product'),
                ),
                SizedBox(height: 50),
              ],
            ),
          )),
    );
  }
}
