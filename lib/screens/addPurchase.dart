import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:inventory_management/models/products_model.dart';
import 'package:inventory_management/models/purchasing_model.dart';

class AddPurchase extends StatefulWidget {
  final String inventoryID;
  final InventoryUser user;
  AddPurchase({Key? key, required this.inventoryID, required this.user})
      : super(key: key);

  @override
  State<AddPurchase> createState() => _AddPurchaseState();
}

class _AddPurchaseState extends State<AddPurchase> {
  int quantity = 0;
  int spending = 0;
  int labour_cost = 0;

  String? image;

  final ImagePicker _picker = ImagePicker();

  TextEditingController total_spending = TextEditingController();

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
        title: const Text('Add Purchase'),
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
                      quantity = int.parse(value);
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Quantity'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      spending = int.parse(value);
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Spending'),
                ),
                SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      labour_cost = int.tryParse(value) ?? 0;
                      int total = spending + labour_cost;
                      total_spending.text = total.toString();
                    });
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Labour Cost'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: total_spending,
                  decoration: InputDecoration(labelText: 'Total Spending'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Timestamp date = Timestamp.now();

                    PurchasingModel pm = PurchasingModel(
                        id: "id",
                        date: date,
                        spendings: spending,
                        quantity: quantity,
                        recieptUrl: image!,
                        labour_cost: labour_cost,
                        total_spending: int.parse(total_spending.text),
                        user_id: widget.user.id);
                    try {
                      await remort_services().createPurchase(
                          pm, widget.inventoryID, pm.recieptUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase Recorded Successfully!'),
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
                  child: Text('Add Purchase'),
                ),
                SizedBox(height: 50),
              ],
            ),
          )),
    );
  }
}
