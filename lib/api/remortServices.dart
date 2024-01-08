import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inventory_management/models/inventoryMemberModel.dart';
import 'package:inventory_management/models/inventory_model.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:inventory_management/models/products_model.dart';
import 'package:inventory_management/models/purchasing_model.dart';
import 'package:inventory_management/models/sales_model.dart';

class remort_services {
  final ref = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<bool> CreateInventory(InventoryModel im) async {
    final insert = ref.collection("Inventories");
    try {
      insert.add({
        "title": im.title,
        "created_on": im.created_on,
        "invite_code": im.invite_code,
        "owner_id": im.owner_id,
        "is_deleted": 0
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<InventoryModel>> getInventories(owner_id) async {
    final snapshot = await ref
        .collection("Inventories")
        .where("owner_id", isEqualTo: owner_id)
        .where('is_deleted', isEqualTo: 0)
        .get();
    final data =
        snapshot.docs.map((e) => InventoryModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<InventoryModel> getInventoryData(inventoryId) async {
    final snapshot = await ref.collection("Inventories").doc(inventoryId).get();
    final data = InventoryModel.fromSnapshot(snapshot);

    return data;
  }

  Future<bool> deleteInventory(String id) async {
    print(id);
    final delete = ref.collection("Inventories");
    try {
      delete.doc(id).update({"isDeleted": 1}).then((value) => {});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteProduct(inventoryID, productID) async {
    final delete =
        ref.collection("Inventories").doc(inventoryID).collection('Products');
    try {
      delete.doc(productID).update({"isDeleted": 1}).then((value) => {});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createProduct(
      ProductModel pm, String inventoryID, String imagePath) async {
    final insert =
        ref.collection("Inventories").doc(inventoryID).collection('Products');

    try {
      // Save product data to Firestore and get the generated product ID
      DocumentReference productRef = await insert.add({
        "title": pm.title,
        "date_added": pm.date_added,
        "date_updated": pm.date_updated,
        "isDeleted": 0,
        "purchased_at": pm.purchased_at,
        "selling_price": pm.selling_price,
        "quantity": pm.quantity,
        "product_category": pm.product_category
      });

      // Upload the image to Firebase Storage using the generated product ID
      String productId = productRef.id;
      String imageUrl = await uploadImage(imagePath, productId);

      // Update the product document in Firestore with the image URL
      await productRef.update({"imageUrl": imageUrl});

      return true;
    } catch (e) {
      print("Error creating product: $e");
      return false;
    }
  }

  Future<String> uploadImage(String imagePath, String productId) async {
    // Reference to the Firebase Storage bucket
    Reference storageReference =
        FirebaseStorage.instance.ref().child("product_images/$productId.jpg");

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(File(imagePath));

    // Get the download URL when the upload is complete
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }

  Future<List<ProductModel>> getProducts(inventory_id) async {
    final snapshot = await ref
        .collection("Inventories")
        .doc(inventory_id)
        .collection('Products')
        .where('isDeleted', isEqualTo: 0)
        .get();
    final data =
        snapshot.docs.map((e) => ProductModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<List<InventoryModel>> getInventoryIDbyInviteCode(invite_code) async {
    final snapshot = await ref
        .collection("Inventories")
        .where('invite_code', isEqualTo: invite_code)
        .get();
    final data =
        snapshot.docs.map((e) => InventoryModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<bool> addMembeViaInviteCode(
      InventoryUser im, String inventoryID) async {
    final insert =
        ref.collection("Inventories").doc(inventoryID).collection('Members');

    try {
      await insert.add({
        "name": im.name,
        "member_id": im.id,
        "joined_on": Timestamp.now(),
        "inventory_id": inventoryID,
        "isDeleted": 0,
        "access":'viewer'

      });
      return true;
    } catch (e) {
      print("Error creating product: $e");
      return false;
    }
  }

  Future<List<InventoryModel>> getJoinedInventories(user_id) async {
    final snapshot = await ref
        .collection("Inventories")
        .where("owner_id", isEqualTo: user_id)
        .where('is_deleted', isEqualTo: 0)
        .get();
    final data =
        snapshot.docs.map((e) => InventoryModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<List<InventoryMember>> getInventoryMembers(inventory_id) async {
    final snapshot = await ref
        .collection("Inventories")
        .doc(inventory_id)
        .collection('Members')
        .where('isDeleted', isEqualTo: 0)
        .get();
    final data =
        snapshot.docs.map((e) => InventoryMember.fromSnapshot(e)).toList();
    return data;
  }

  Future<List<InventoryModel>> getAllInventories() async {
    final snapshot = await ref
        .collection("Inventories")
        .where('is_deleted', isEqualTo: 0)
        .get();
    final data =
        snapshot.docs.map((e) => InventoryModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<bool> updateProduct(
      String inventoryID, ProductModel pm, String imagePath) async {
    final productRef = ref
        .collection("Inventories")
        .doc(inventoryID)
        .collection('Products')
        .doc(pm.id);

    try {
      // Update product data in Firestore
      await productRef.update({
        "title": pm.title,
        "date_updated": pm.date_updated,
        "purchased_at": pm.purchased_at,
        "selling_price": pm.selling_price,
        "product_category": pm.product_category,
        "quantity": pm.quantity,
      });

      // Check if a new image is provided for update
      if (imagePath.isNotEmpty) {
        // Upload the new image to Firebase Storage
        String imageUrl = await uploadImage(imagePath, pm.id);

        // Update the product document in Firestore with the new image URL
        await productRef.update({"imageUrl": imageUrl});
      }

      return true;
    } catch (e) {
      print("Error updating product: $e");
      return false;
    }
  }

  Future<bool> createSale(SalesModel sm, inventoryID) async {
    final insert =
        ref.collection("Inventories").doc(inventoryID).collection('Sales');

    try {
      // Save product data to Firestore and get the generated product ID
      await insert.add({
        "sale_date": sm.sale_date,
        "buyer": sm.buyer,
        "profit": sm.profit,
        "purchase_total": sm.purchase_total,
        "seller": sm.seller,
        "sold_quantity": sm.sold_quantity,
        "total": sm.total,
        "seller_id": sm.seller_id
      });

      return true;
    } catch (e) {
      print("Error creating product: $e");
      return false;
    }
  }

  Future<List<SalesModel>> getSales(inventoryID) async {
    final snapshot = await ref
        .collection("Inventories")
        .doc(inventoryID)
        .collection("Sales")
        .get();
    final data = snapshot.docs.map((e) => SalesModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<bool> updateProductQuantity(
      String inventoryID, productID, productQuantity) async {
    final productRef = ref
        .collection("Inventories")
        .doc(inventoryID)
        .collection('Products')
        .doc(productID);

    try {
      // Update product data in Firestore
      await productRef.update({
        "quantity": productQuantity,
      });

      return true;
    } catch (e) {
      print("Error updating product: $e");
      return false;
    }
  }

  Future<bool> createPurchase(
      PurchasingModel pm, String inventoryID, String imagePath) async {
    final insert =
        ref.collection("Inventories").doc(inventoryID).collection('Purchase');

    try {
      // Save product data to Firestore and get the generated product ID
      DocumentReference productRef = await insert.add({
        "date": pm.date,
        "quantity": pm.quantity,
        "total_spending": pm.total_spending,
        "spendings": pm.spendings,
        "labour_cost": pm.labour_cost,
        "user_id": pm.user_id,
        "isDeleted": 0
      });

      // Upload the image to Firebase Storage using the generated product ID
      String productId = productRef.id;
      String imageUrl = await uploadRecieptImage(imagePath, productId);

      // Update the product document in Firestore with the image URL
      await productRef.update({"recieptUrl": imageUrl});

      return true;
    } catch (e) {
      print("Error creating product: $e");
      return false;
    }
  }

  Future<String> uploadRecieptImage(String imagePath, String productId) async {
    // Reference to the Firebase Storage bucket
    Reference storageReference =
        FirebaseStorage.instance.ref().child("reciept_images/$productId.jpg");

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageReference.putFile(File(imagePath));

    // Get the download URL when the upload is complete
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await taskSnapshot.ref.getDownloadURL();

    return imageUrl;
  }

  Future<bool> updatePurchase(
      String inventoryID, PurchasingModel pm, String imagePath) async {
    final productRef = ref
        .collection("Inventories")
        .doc(inventoryID)
        .collection('Purchase')
        .doc(pm.id);

    try {
      // Update product data in Firestore
      await productRef.update({
        "quantity": pm.quantity,
        "total_spending": pm.total_spending,
        "spendings": pm.spendings,
        "labour_cost": pm.labour_cost,
      });

      // Check if a new image is provided for update
      if (imagePath.isNotEmpty) {
        // Upload the new image to Firebase Storage
        String imageUrl = await uploadImage(imagePath, pm.id);

        // Update the product document in Firestore with the new image URL
        await productRef.update({"recieptUrl": imageUrl});
      }

      return true;
    } catch (e) {
      print("Error updating product: $e");
      return false;
    }
  }

  Future<List<PurchasingModel>> getPurchases(inventoryID) async {
    final snapshot = await ref
        .collection("Inventories")
        .doc(inventoryID)
        .collection("Purchase")
        .get();
    final data =
        snapshot.docs.map((e) => PurchasingModel.fromSnapshot(e)).toList();
    return data;
  }

  Future<bool> deletePurchase(inventoryID, purchsaeID) async {
    final delete =
        ref.collection("Inventories").doc(inventoryID).collection('Purchase');
    try {
      delete.doc(purchsaeID).update({"isDeleted": 1}).then((value) => {});
      return true;
    } catch (e) {
      return false;
    }
  }

   Future<List<PurchasingModel>> getTotalPurchaing(inventoryID) async {
    final snapshot = await ref
        .collection("Inventories")
        .doc(inventoryID)
        .collection("Purchase")
        .get();
    final data =
        snapshot.docs.map((e) => PurchasingModel.fromSnapshot(e)).toList();
    return data;
  }

   Future<bool> changeAccess(inventoryID, memeberID,access) async {
    final update =
        ref.collection("Inventories").doc(inventoryID).collection('Members');
    try {
      update.doc(memeberID).update({"access": access}).then((value) => {});
      return true;
    } catch (e) {
      return false;
    }
  }

}
