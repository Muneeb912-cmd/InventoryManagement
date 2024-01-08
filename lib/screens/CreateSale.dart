import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/inventory_model.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:inventory_management/models/productSale_model.dart';
import 'package:inventory_management/models/products_model.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/models/sales_model.dart';
import 'package:inventory_management/screens/UpdateProduct.dart';
import 'package:inventory_management/screens/addProduct.dart';

class CreateSale extends StatefulWidget {
  final InventoryUser user;
  final String inventoryID;
  const CreateSale({super.key, required this.user, required this.inventoryID});

  @override
  State<CreateSale> createState() => _CreateSaleState();
}

class _CreateSaleState extends State<CreateSale> {
  List<ProductModel>? products;
  late InventoryModel inventoryData;
  List<ProductSaleModel> productSales = [];
  bool isLoaded = false;
  bool isEmpty = true;
  String title = '';
  int quantity = 0;
  int purchased_at = 0;
  String dropdownValue = '';
  bool isLoaded1 = false;
  List<String> categories = [];
  late List<TextEditingController> quantityControllers = List.generate(
      products?.length ?? 0, (index) => TextEditingController(text: '0'));
  TextEditingController buyer_name = TextEditingController(text: '');
  TextEditingController seller_name = TextEditingController();

  @override
  void initState() {
    super.initState();
    getInventoryData();
    getProducts("");
    seller_name = TextEditingController(text: widget.user.name);
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

  getProducts(String filter) async {
    products = await remort_services().getProducts(widget.inventoryID);
    if (products != null) {
      if (products!.isNotEmpty) {
        setState(() {
          getCategories();
          isEmpty = false;
          isLoaded1 = true;
        });
      }
    }
    if (filter != '') {
      List<ProductModel> filteredProducts = products!
          .where((product) => product.product_category == filter)
          .toList();
      setState(() {
        products = filteredProducts;
      });
    }
  }

  getCategories() {
    if (products != null) {
      for (var items in products!) {
        if (!categories.contains(items.product_category)) {
          setState(() {
            categories.add(items.product_category);
          });
        }
      }
    }
  }

  Future<void> _refreshData() async {
    getProducts("");
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
        title: Text('Create Sale'),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 350,
                          child: Text(
                            "From the list Below select the quantity to generate sale:",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      child: Row(
                        children: [
                          Text("Filter By Product Category : "),
                          DropdownMenu<String>(
                            initialSelection: categories.first,
                            onSelected: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                dropdownValue = value!;
                                getProducts(dropdownValue);
                              });
                            },
                            dropdownMenuEntries: categories
                                .map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                  value: value, label: value);
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(color: Colors.brown.shade300),
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
                                            getProducts("");
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
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Text("Fill the following:"),
                              SizedBox(
                                height: 15,
                              )
                            ],
                          ),
                        ),
                        TextField(
                          controller: seller_name,
                          decoration: const InputDecoration(
                            labelText: 'Seller Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        TextField(
                          controller: buyer_name,
                          decoration: const InputDecoration(
                            labelText: 'Buyer Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            int purchasePrice = 0;
                            int totalSalePrice = 0;
                            int soldQuantity = 0;
                            if (productSales.isNotEmpty) {
                              for (var items in productSales) {
                                purchasePrice = purchasePrice +
                                    (items.purchased_at * items.sold_quantity);
                                totalSalePrice = totalSalePrice +
                                    (items.selling_price * items.sold_quantity);
                                soldQuantity =
                                    soldQuantity + items.sold_quantity;
                              }
                            }
                            int profit = totalSalePrice - purchasePrice;
                            SalesModel sm = SalesModel(
                                id: 'id',
                                sale_date: Timestamp.now(),
                                buyer: buyer_name.text,
                                profit: profit,
                                purchase_total: purchasePrice,
                                seller: widget.user.name,
                                sold_quantity: soldQuantity,
                                seller_id: widget.user.id,
                                total: totalSalePrice);

                            showBillDetailsDialog(context, sm);
                          },
                          child: const Text('Create Bill'),
                        ),
                        const SizedBox(
                          height: 50,
                        )
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  void showBillDetailsDialog(BuildContext context, SalesModel salesModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bill Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Buyer: ${salesModel.buyer}'),
              Text('Seller: ${salesModel.seller}'),
              Text('Sold Quantity: ${salesModel.sold_quantity}'),
              Text('Purchase Total: Rs.${salesModel.purchase_total}'),
              Text('Total Sale Price: Rs.${salesModel.total}'),
              Text('Profit: Rs.${salesModel.profit}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  for (var items in productSales) {
                    for (var items1 in products!) {
                      if (items.id == items1.id) {
                        int quantity = items1.quantity - items.sold_quantity;
                        await remort_services().updateProductQuantity(
                            widget.inventoryID, items.id, quantity);
                      }
                    }
                  }
                  await remort_services()
                      .createSale(salesModel, widget.inventoryID);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sale recorded successfully!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('An error might have occured'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void updateQuantity(
    int index,
  ) {
    int total = int.parse(quantityControllers[index].text) *
        products![index].selling_price;
    int purchaseTotal = int.parse(quantityControllers[index].text) *
        products![index].purchased_at;

    int profit = total - purchaseTotal;
    ProductSaleModel sm = ProductSaleModel(
      id: products![index].id,
      purchased_at: products![index].purchased_at,
      selling_price: products![index].selling_price,
      quantity: products![index].quantity,
      title: products![index].title,
      profit: profit,
      purchase_total: purchaseTotal,
      sold_quantity: int.parse(quantityControllers[index].text),
      total: total,
    );
    List<ProductSaleModel>? productsSalesCopy = List.from(productSales);
    if (productsSalesCopy.isNotEmpty) {
      for (var items in productsSalesCopy) {
        if (items.id != products![index].id) {
          productSales.add(sm);
        } else {
          productSales.remove(items);
          productSales.add(sm);
        }
      }
    } else {
      productSales.add(sm);
    }
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
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Price: ",
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Image.network(
                                      products![index].imageUrl,
                                      height: 200,
                                      width: 270,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    int newQuantity = int.parse(
                                            quantityControllers[index].text) -
                                        1;
                                    if (newQuantity >= 0) {
                                      quantityControllers[index].text =
                                          newQuantity.toString();
                                    }
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                                SizedBox(
                                  width: 50, // Adjust the width as needed
                                  child: TextField(
                                    controller: quantityControllers[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    int newQuantity = int.parse(
                                            quantityControllers[index].text) +
                                        1;
                                    if (newQuantity <
                                        products![index].quantity) {
                                      quantityControllers[index].text =
                                          newQuantity.toString();
                                    }
                                  },
                                  icon: Icon(Icons.add),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    updateQuantity(index);
                                  },
                                  child: Text('Confirm'),
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
}
