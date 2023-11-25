import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inventory_management/models/inventory_user.dart';
import 'package:local_auth/local_auth.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

 
  static InventoryUser user_ = InventoryUser(
      image: 'image',
      about: 'about',
      name: 'name',
      createdAt: 'createdAt',
      id: 'id',
      email: 'email',
      pushToken: 'pushToken');

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        user_.pushToken = t;
        print('token ' + t);
        log('Push Token: $t');
      }
    });

    // for handling foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Got a message whilst in the foreground!');
      log('Message data: ${message.data}');

      if (message.notification != null) {
        log('Message also contained a notification: ${message.notification}');
      }
    });
  }


  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }


  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        user_ = InventoryUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        log('My Data: ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<InventoryUser> getUserInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        user_ = InventoryUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();        
      } else {
        await createUser().then((value) => getUserInfo());
      }      
    });
    return (InventoryUser(
            image: user_.image,
            about: user_.about,
            name: user_.name,
            createdAt: user_.createdAt,
            id: user_.id,
            email: user_.email,
            pushToken: user_.pushToken));
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = InventoryUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Lets build Our Buisness!",
        image: user.photoURL.toString(),
        createdAt: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }


  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': user_.name,
      'about': user_.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    user_.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': user_.image});
  }

 
  //biometric authentication
  static Future<bool> authenticate() async {
    late final LocalAuthentication auth;
    auth = LocalAuthentication();
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: "Verify Yourself to Continue!",
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print(e);
      return false;
    }
  }

  
}
