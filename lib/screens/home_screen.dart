import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:inventory_management/api/apis.dart';
import 'package:inventory_management/api/remortServices.dart';
import 'package:inventory_management/models/inventoryMemberModel.dart';
import 'package:inventory_management/models/inventory_model.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:inventory_management/screens/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/screens/inventoryScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<InventoryModel> _list = [];
  final List<InventoryModel> _searchList = [];
  List<InventoryModel>? inventories;
  List<InventoryModel>? joinedInventories;

  bool _isSearching = false;
  late InventoryUser user;
  late InventoryUser userInfo;
  bool visible = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    user = APIs.user_;
    getSelfInfo();
  }

  void getSelfInfo() async {
    userInfo = await APIs.getUserInfo();
    getInventories(userInfo.id);
  }

  void getInventories(String owner_id) async {
    inventories = await remort_services().getInventories(owner_id);
    if (inventories != null) {
      getJoinedInventories();
      setState(() {
        visible = true;
      });
    }
  }

  void getJoinedInventories() async {
    List<InventoryModel> allInventories =
        await remort_services().getAllInventories();
    List<InventoryMember> finalList = [];
    for (var inv in allInventories) {
      if (inv.owner_id != userInfo.id) {
        List<InventoryMember> l1 =
            await remort_services().getInventoryMembers(inv.id);
        for (var items in l1) {
          if (items.member_id == userInfo.id) {
            finalList.add(items);
          }
        }
      }
    }

    if (finalList.isNotEmpty) {
      for (var items in finalList) {
        InventoryModel im =
            await remort_services().getInventoryData(items.inventory_id);
        if (!inventories!.contains(im)) {
          setState(() {
            inventories!.add(im);
          });
          print(inventories);
        }
      }
    }
  }

  Future<void> _refreshData() async {
    getJoinedInventories();
  }

  toggleDrawer() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openEndDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      //app bar
      appBar: AppBar(
        backgroundColor: Colors.white60,
        leading: IconButton(
            onPressed: () {
              toggleDrawer();
            },
            icon: Icon(Icons.menu)),
        title: _isSearching
            ? TextField(
                decoration: const InputDecoration(
                    border: InputBorder.none, hintText: 'Inventory Title'),
                autofocus: true,
                style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                //when search text changes then updated search list
                onChanged: (val) {
                  //search logic
                  _searchList.clear();

                  for (var i in _list) {
                    if (i.title.toLowerCase().contains(val.toLowerCase())) {
                      _searchList.add(i);
                      setState(() {
                        _searchList;
                      });
                    }
                  }
                },
              )
            : const Text('Inventories'),
        actions: [
          //search user button
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(_isSearching
                    ? CupertinoIcons.clear_circled_solid
                    : Icons.search)),
          ),

          //more features button
          // IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (_) => ProfileScreen(user: APIs.me)));
          //     },
          //     icon: const Icon(Icons.more_vert))
        ],
      ),
      //floating button to add new user
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Visibility(child: _FloatingActionButton()),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: Visibility(
              child: inventoriesListView(),
              visible: visible,
              replacement: const Center(
                child: CircularProgressIndicator(),
              ),
            )),
      ),
    );
  }

  Icon _icon = const Icon(Icons.add);
  FloatingActionButton _FloatingActionButton() {
    return FloatingActionButton(
        backgroundColor: Colors.blue.shade100,
        elevation: 10.0,
        onPressed: () {
          print('click');
          _showInventoryDialog(context);
        },
        child: _icon);
  }

  ListView inventoriesListView() {
    ScrollController scollBarController1 = ScrollController();
    return ListView.builder(
      itemCount: inventories?.length,
      itemBuilder: (context, index) {
        const Text('Swipe right to Access Delete method');

        return Slidable(
          // Specify a key if the Slidable is dismissible.
          key: Key(inventories![index].id),

          // The start action pane is the one at the left or the top side.
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(
              key: Key(inventories![index].id),
              onDismissed: () async {
                try {
                  await remort_services()
                      .deleteInventory(inventories![index].id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Inventory Deleted Successfully!'),
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

          // The end action pane is the one at the right or the bottom side.
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: (context) {},
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.shade500,
                icon: Icons.edit,
                label: 'Edit',
              ),
            ],
          ),
          child: Container(
              width: 10000,
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InventoryScreen(
                            user: userInfo,
                            inventoryID: inventories![index].id),
                      ),
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
                                inventories![index].title,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 18),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "created on: ",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.black),
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd ').format(
                                    inventories![index].created_on.toDate()),
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

  Future<void> _showInventoryDialog(BuildContext context) async {
    TextEditingController _inventoryNameController = TextEditingController();
    TextEditingController _joiningCodeController = TextEditingController();

    String generateInviteCode() {
      const String characters =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*_-+=<>/'; // Include special characters as needed
      final Random random = Random();
      final StringBuffer codeBuffer = StringBuffer();

      for (int i = 0; i < 8; i++) {
        final int randomIndex = random.nextInt(characters.length);
        codeBuffer.write(characters[randomIndex]);
      }

      return codeBuffer.toString();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create/Join an Inventory'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _inventoryNameController,
                decoration: InputDecoration(labelText: 'Inventory Name'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  // Handle create or join logic here
                  String inventoryName = _inventoryNameController.text;
                  String inviteCode = generateInviteCode();
                  Timestamp createdOn = Timestamp.now();
                  InventoryModel im = InventoryModel(
                      created_on: createdOn,
                      id: 'id',
                      title: inventoryName,
                      invite_code: inviteCode,
                      owner_id: userInfo.id);
                  try {
                    remort_services().CreateInventory(im);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Inventory created successfully!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    getInventories(userInfo.id);
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error might have occured $e'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Create'),
              ),
              SizedBox(height: 10),
              Text('Or Join an Inventory'),
              TextField(
                controller: _joiningCodeController,
                decoration: InputDecoration(labelText: 'Joining Code'),
              ),
              TextButton(
                onPressed: () async {
                  String joiningCode = _joiningCodeController.text;
                  try {
                    List<InventoryModel> inv = await remort_services()
                        .getInventoryIDbyInviteCode(joiningCode);
                    if (inv.isNotEmpty) {
                      List<InventoryMember> mem = await remort_services()
                          .getInventoryMembers(inv[0].id);
                      if (mem.isNotEmpty) {
                        for (var members in mem) {
                          if (userInfo.id != members.member_id) {
                            await remort_services()
                                .addMembeViaInviteCode(userInfo, inv[0].id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'You have already joined the inventory!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                        }
                      } else {
                        if (userInfo.id == inv[0].owner_id) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('You are the owner of the inventory!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          await remort_services()
                              .addMembeViaInviteCode(userInfo, inv[0].id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Joined Inventory!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error might have occured $e'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  Navigator.of(context).pop();
                },
                child: Text('Join'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
