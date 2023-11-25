import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/api/remortServices.dart';

import 'package:inventory_management/models/purchasing_model.dart';

class UpdatePurchase extends StatefulWidget {
  final String inventoryID;
  final PurchasingModel purchase;
  UpdatePurchase({Key? key, required this.inventoryID, required this.purchase})
      : super(key: key);

  @override
  State<UpdatePurchase> createState() => _AddProductState();
}

class _AddProductState extends State<UpdatePurchase> {
  String? image;

  TextEditingController quantity = TextEditingController();
  TextEditingController spendings = TextEditingController();
  TextEditingController labourCost = TextEditingController();
  TextEditingController totalSpending = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quantity = TextEditingController(text: widget.purchase.quantity.toString());
    spendings =
        TextEditingController(text: widget.purchase.spendings.toString());
    labourCost =
        TextEditingController(text: widget.purchase.labour_cost.toString());
    totalSpending =
        TextEditingController(text: widget.purchase.total_spending.toString());
    image = widget.purchase.recieptUrl;
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
        title: const Text('View/Update Purchase'),
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
                  controller: quantity,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: spendings,
                  decoration: InputDecoration(
                    labelText: 'Spendings',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: labourCost,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Labour Cost'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: totalSpending,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Spendings'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    Timestamp date = Timestamp.now();
                    PurchasingModel pm = PurchasingModel(
                        id: widget.purchase.id,
                        date: date,
                        spendings: int.parse(spendings.text),
                        quantity: int.parse(quantity.text),
                        recieptUrl: image!,
                        labour_cost: int.parse(labourCost.text),
                        total_spending: int.parse(totalSpending.text),
                        user_id: '');
                    try {
                      await remort_services()
                          .updatePurchase(widget.inventoryID, pm, image!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Purchase Updated Successfully!'),
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
