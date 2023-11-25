import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/inventoryMemberModel.dart';
import 'package:inventory_management/models/inventory_model.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:intl/intl.dart';
import 'package:inventory_management/models/products_model.dart';
import 'package:inventory_management/models/purchasing_model.dart';
import 'package:inventory_management/models/sales_model.dart';
import 'package:inventory_management/screens/purchase_screen.dart';

class SettingScreen extends StatefulWidget {
  final InventoryUser user;
  final String inventoryID;
  const SettingScreen(
      {super.key, required this.user, required this.inventoryID});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  TextEditingController inviteCode = TextEditingController();

  List<InventoryMember>? members;
  List<SalesModel>? sales;
  bool isMembersFetched = false;
  bool isSaledFetched = false;
  int profit = 0;
  int soldQuantity = 0;
  int totalSaleAmount = 0;
  int totalPurchasing = 0;
  int totalProducts = 0;
  int totalSales = 0;

  @override
  void initState() {
    super.initState();
    getMemebrs();
    getInventoryData();
    getSales();
  }

  getMemebrs() async {
    members = await remort_services().getInventoryMembers(widget.inventoryID);
    if (members != null) {
      setState(() {
        isMembersFetched = true;
      });
    }
  }

  getInventoryData() async {
    InventoryModel im =
        await remort_services().getInventoryData(widget.inventoryID);
    inviteCode.text = im.invite_code;
  }

  getTotalProducts() async {
    List<ProductModel> products =
        await remort_services().getProducts(widget.inventoryID);
    setState(() {
      totalProducts = products.length;
    });
  }

  getSales() async {
    sales = await remort_services().getSales(widget.inventoryID);
    if (sales != null) {
      setState(() {
        totalSales = sales!.length;
      });
      setState(() {
        for (var items in sales!) {
          setState(() {
            profit = profit + items.profit;
            soldQuantity = soldQuantity + items.sold_quantity;
            totalSaleAmount = totalSaleAmount + items.total;
            getTotalPurchasing();
          });
        }
        getTotalProducts();
        isSaledFetched = true;
      });
    }
  }

  getTotalPurchasing() async {
    List<PurchasingModel> list =
        await remort_services().getTotalPurchaing(widget.inventoryID);
    if (list.isNotEmpty) {
      for (var items in list) {
        setState(() {
          totalPurchasing = totalPurchasing + items.total_spending;
        });
      }
    }
  }

  Future<void> copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite Code copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
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
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Dashboard'),
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
                          builder: (context) => PurchaseScreen(
                              inventoryID: widget.inventoryID,
                              user: widget.user),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_document),
                  ),
                ],
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Invite Code : ",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: inviteCode,
                    decoration: const InputDecoration(
                      labelText: 'Invite Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      copyToClipboard(inviteCode.text);
                    },
                    icon: const Icon(Icons.copy))
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Inventory Members :",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Container(
                decoration: BoxDecoration(border: Border.all()),
                height: 180,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      visible: isMembersFetched,
                      child: members!.isEmpty
                          ? const Text("No Members")
                          : membersListView()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 90,
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade300,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text(
                                'Total Sales : ' + totalSales.toString(),
                                style: TextStyle(fontSize: 15),
                              ))),
                        ),
                        Container(
                          height: 90,
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade300,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text(
                                'Total Profit : ' + profit.toString(),
                                style: TextStyle(fontSize: 15),
                              ))),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 90,
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade300,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text(
                                'Sold Quantity : ' + soldQuantity.toString(),
                                style: TextStyle(fontSize: 15),
                              ))),
                        ),
                        Container(
                          height: 90,
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade300,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text(
                                'Total Purchasing : ' +
                                    totalPurchasing.toString(),
                                style: TextStyle(fontSize: 15),
                              ))),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0, bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 90,
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade300,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text(
                                'Total Income : ' + totalSaleAmount.toString(),
                                style: TextStyle(fontSize: 15),
                              ))),
                        ),
                        Container(
                          height: 90,
                          width: 140,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: Colors.grey.shade300,
                          ),
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Center(
                                  child: Text(
                                'Total Products : ' + totalProducts.toString(),
                                style: TextStyle(fontSize: 15),
                              ))),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  ListView membersListView() {
    ScrollController scollBarController1 = ScrollController();
    return ListView.builder(
      itemCount: members?.length,
      itemBuilder: (context, index) {
        const Text('Swipe right to Access Delete method');

        return Slidable(
          // Specify a key if the Slidable is dismissible.
          key: Key(members![index].id),

          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(
              key: Key(members![index].id),
              onDismissed: () async {},
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
                  onTap: () {},
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
                                    fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                members![index].name,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Joined on: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.black),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd ')
                                    .format(members![index].joined_on.toDate()),
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.black),
                              ),
                            ],
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
