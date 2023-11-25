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
import 'package:inventory_management/screens/CreateSale.dart';
import 'package:inventory_management/screens/UpdateProduct.dart';
import 'package:inventory_management/screens/addProduct.dart';
import 'package:inventory_management/screens/settings_screen.dart';

class InventoryScreen extends StatefulWidget {
  final InventoryUser user;
  final String inventoryID;
  const InventoryScreen(
      {super.key, required this.user, required this.inventoryID});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<ProductModel>? products;
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
    getProducts();
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

  getProducts() async {
    products = await remort_services().getProducts(widget.inventoryID);
    if (products != null) {
      if (products!.isNotEmpty) {
        setState(() {
          isEmpty = false;
          isLoaded1 = true;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    getProducts();
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
        title: isLoaded ? Text(inventoryData.title) : Text("Loading..."),
        actions: [
          //search user button
          Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateSale(
                              user: widget.user,
                              inventoryID: widget.inventoryID),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_document),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(
                              inventoryID: widget.inventoryID,
                              user: widget.user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                  ),
                ],
              )),
        ],
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
                          Text("Add Products to view"),
                          IconButton(
                              onPressed: () {
                                getProducts();
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
      itemCount: products?.length,
      itemBuilder: (context, index) {
        const Text('Swipe right to Access Delete method');

        return Slidable(
          // Specify a key if the Slidable is dismissible.
          key: Key(products![index].id),

          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(
              key: Key(products![index].id),
              onDismissed: () async {
                try {
                  await remort_services()
                      .deleteProduct(inventoryData.id, products![index].id);
                  if (products!.isEmpty) {
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
                    ProductModel pm = ProductModel(
                        id: products![index].id,
                        date_added: products![index].date_added,
                        date_updated: products![index].date_updated,
                        imageUrl: products![index].imageUrl,
                        purchased_at: products![index].purchased_at,
                        selling_price: products![index].selling_price,
                        quantity: products![index].quantity,
                        title: products![index].title,
                        product_category: products![index].product_category);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UpdateProduct(
                              inventoryID: widget.inventoryID, product: pm)),
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
                                products![index].title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
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
                                products![index].quantity.toString(),
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
                                  products![index].imageUrl,
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
                                  "PurchasePrice: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                Text(
                                  products![index].purchased_at.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Selling Price: ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                                Text(
                                  products![index].selling_price.toString(),
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
                  builder: (_) => AddProduct(
                        inventoryID: widget.inventoryID,
                      )));
        },
        child: _icon);
  }
}
