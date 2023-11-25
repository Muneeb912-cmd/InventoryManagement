import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/products_model.dart';

class UpdateProduct extends StatefulWidget {
  final String inventoryID;
  final ProductModel product;
  UpdateProduct({Key? key, required this.inventoryID, required this.product})
      : super(key: key);

  @override
  State<UpdateProduct> createState() => _AddProductState();
}

class _AddProductState extends State<UpdateProduct> {
  String title = '';
  int quantity = 0;
  int purchased_at = 0;
  int selling_price = 0;

  String? image;

  TextEditingController productTitle = TextEditingController();
  TextEditingController productCategory = TextEditingController();
  TextEditingController productQuantity = TextEditingController();
  TextEditingController productPurchasedPrice = TextEditingController();
  TextEditingController productSellingPrice = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productTitle = TextEditingController(text: widget.product.title);
    productQuantity =
        TextEditingController(text: widget.product.quantity.toString());
    productPurchasedPrice =
        TextEditingController(text: widget.product.purchased_at.toString());
    productSellingPrice =
        TextEditingController(text: widget.product.selling_price.toString());
    image = widget.product.imageUrl;
    productCategory =
        TextEditingController(text: widget.product.product_category.toString());
  }

  final ImagePicker _picker = ImagePicker();

  bool updatePhoto = false;

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
        title: const Text('View/Update Product'),
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
                  onPressed: () {
                    _getImage(ImageSource.camera);
                    setState(() {
                      updatePhoto = true;
                    });
                  },
                  child: Text('Take Photo'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _getImage(ImageSource.gallery);
                    setState(() {
                      updatePhoto = true;
                    });
                  },
                  child: Text('Select Photo'),
                ),
                SizedBox(height: 16),
                if (image != null) ...[
                  updatePhoto == false
                      ? Image.network(
                          image!,
                          height: 250,
                          width: 100,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(image!),
                          height: 250,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                  SizedBox(height: 16),
                ],
                TextField(
                  controller: productTitle,
                  decoration: InputDecoration(
                    labelText: 'Product Title',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: productCategory,
                  decoration: InputDecoration(
                    labelText: 'Product Category',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: productQuantity,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: productPurchasedPrice,
                  onChanged: (value) {
                    setState(() {
                      purchased_at = int.tryParse(value) ?? 0;
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: 'Purchased price (Rs.)'),
                ),
                TextField(
                  controller: productSellingPrice,
                  onChanged: (value) {
                    setState(() {
                      purchased_at = int.tryParse(value) ?? 0;
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
                        id: widget.product.id,
                        date_added: date_added,
                        date_updated: date_updated,
                        imageUrl: image!,
                        purchased_at: int.parse(productPurchasedPrice.text),
                        quantity: int.parse(productQuantity.text),
                        title: productTitle.text,
                        selling_price: int.parse(productSellingPrice.text),                        
                        product_category: productCategory.text);
                    try {
                      await remort_services()
                          .updateProduct(widget.inventoryID, pm, image!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Product $title Updated Successfully!'),
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
                  child: Text('Update Product'),
                ),
                SizedBox(height: 50),
              ],
            ),
          )),
    );
  }
}
