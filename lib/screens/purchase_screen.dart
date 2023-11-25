import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/inventory_model.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:inventory_management/models/products_model.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/models/purchasing_model.dart';
import 'package:inventory_management/screens/CreateSale.dart';
import 'package:inventory_management/screens/UpdateProduct.dart';
import 'package:inventory_management/screens/addProduct.dart';
import 'package:inventory_management/screens/addPurchase.dart';
import 'package:inventory_management/screens/settings_screen.dart';
import 'package:inventory_management/screens/updatePurchase.dart';

class PurchaseScreen extends StatefulWidget {
  final InventoryUser user;
  final String inventoryID;
  const PurchaseScreen(
      {super.key, required this.user, required this.inventoryID});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<PurchasingModel>? purchase;
  late InventoryModel inventoryData;
  bool isLoaded = false;
  bool isEmpty = true;
  String title = '';
  int quantity = 0;
  int purchased_at = 0;
  bool isLoaded1 = false;

  @override
  void initState() {
    super.initState();
    getInventoryData();
    getPurchases();
  }

  getInventoryData() async {
    inventoryData =
        await remort_services().getInventoryData(widget.inventoryID);
    if (inventoryData.id != '') {
      setState(() {
        isLoaded = true;
      });
    }
  }

  getPurchases() async {
    purchase = await remort_services().getPurchases(widget.inventoryID);
    if (purchase != null) {
      if (purchase!.isNotEmpty) {
        setState(() {
          isEmpty = false;
          isLoaded1 = true;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    getPurchases();
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
            icon: Icon(Icons.arrow_back)),
        title: const Text("Purchasings"),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Visibility(child: _FloatingActionButton()),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Visibility(
            child: productsListView(),
            visible: isLoaded1,
            replacement: Center(
              child: isEmpty == true
                  ? Center(
                      child: Column(
                        children: [
                          Text("Purchasings"),
                          IconButton(
                              onPressed: () {
                                getPurchases();
                              },
                              icon: Icon(Icons.refresh))
                        ],
                      ),
                    )
                  : CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }

  ListView productsListView() {
    ScrollController scollBarController1 = ScrollController();
    return ListView.builder(
      itemCount: purchase?.length,
      itemBuilder: (context, index) {
        const Text('Swipe right to Access Delete method');

        return Slidable(
          // Specify a key if the Slidable is dismissible.
          key: Key(purchase![index].id),

          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(
              key: Key(purchase![index].id),
              onDismissed: () async {
                try {
                  await remort_services()
                      .deletePurchase(inventoryData.id, purchase![index].id);
                  if (purchase!.isEmpty) {
                    setState(() {
                      isLoaded1 = false;
                      isEmpty = true;
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Product Deleted Successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('An error might have occured! $e'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: null,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade500,
                icon: Icons.delete,
                label: 'Swipe Right to Delete',
              ),
            ],
          ),

          child: Container(
              width: 10000,
              child: GestureDetector(
                  onTap: () {
                    PurchasingModel pm = PurchasingModel(
                        id: purchase![index].id,
                        date: purchase![index].date,
                        spendings: purchase![index].spendings,
                        quantity: purchase![index].quantity,
                        recieptUrl: purchase![index].recieptUrl,
                        labour_cost: purchase![index].labour_cost,
                        total_spending: purchase![index].total_spending,
                        user_id: purchase![index].user_id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdatePurchase(
                              inventoryID: widget.inventoryID, purchase: pm)),
                    );
                  },
                  child: Card(
                    color: Colors.blue.shade100,
                    shadowColor: Colors.white,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                (index + 1).toString() + '.',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Purchase ${index + 1}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "Date: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd ')
                                    .format(purchase![index].date.toDate()),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Image.network(
                                  purchase![index].recieptUrl,
                                  height: 250,
                                  width: 300,
                                  fit: BoxFit.fill,
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Total Spending : ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                Text(
                                  purchase![index].total_spending.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Quantity: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                Text(
                                  purchase![index].quantity.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))),
        );
      },
    );
  }

  Icon _icon = const Icon(Icons.add);
  FloatingActionButton _FloatingActionButton() {
    return FloatingActionButton(
        backgroundColor: Colors.blue.shade100,
        elevation: 10.0,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => AddPurchase(
                        inventoryID: widget.inventoryID,
                        user: widget.user,
                      )));
        },
        child: _icon);
  }
}
