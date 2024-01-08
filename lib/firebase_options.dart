// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDD9ePwTwvGtoSTAw8e6vU3xkkwUFk6rrg',
    appId: '1:84023550602:web:bb6dbd6e932ef1537f8373',
    messagingSenderId: '84023550602',
    projectId: 'bc-jewlery',
    authDomain: 'bc-jewlery.firebaseapp.com',
    storageBucket: 'bc-jewlery.appspot.com',
    measurementId: 'G-E2W9C0PD5X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCtWBSNa63fs1QfM-O10HzuzS9wE45fizU',
    appId: '1:84023550602:android:52943912b45013b27f8373',
    messagingSenderId: '84023550602',
    projectId: 'bc-jewlery',
    storageBucket: 'bc-jewlery.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCm_9b0IDbACwREUP8My1c1MPvQgPkI5ow',
    appId: '1:84023550602:ios:4f171c30bc5f60b17f8373',
    messagingSenderId: '84023550602',
    projectId: 'bc-jewlery',
    storageBucket: 'bc-jewlery.appspot.com',
    iosBundleId: 'com.example.inventoryManagement',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCm_9b0IDbACwREUP8My1c1MPvQgPkI5ow',
    appId: '1:84023550602:ios:d9ea77b0ff36eec87f8373',
    messagingSenderId: '84023550602',
    projectId: 'bc-jewlery',
    storageBucket: 'bc-jewlery.appspot.com',
    iosBundleId: 'com.example.inventoryManagement.RunnerTests',
  );
}