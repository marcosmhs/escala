// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7hhFs7XpwHniwzDoltywuU2dWO7h9qIw',
    appId: '1:283635354027:android:94ce3b554b6734b87aeaee',
    messagingSenderId: '283635354027',
    projectId: 'that-exotic-bug-escala',
    databaseURL: 'https://that-exotic-bug-escala-default-rtdb.firebaseio.com',
    storageBucket: 'that-exotic-bug-escala.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFlT7yedqcKRfQ491uu9DZVd0rnX4O1Qo',
    appId: '1:283635354027:ios:1659730c284525837aeaee',
    messagingSenderId: '283635354027',
    projectId: 'that-exotic-bug-escala',
    databaseURL: 'https://that-exotic-bug-escala-default-rtdb.firebaseio.com',
    storageBucket: 'that-exotic-bug-escala.appspot.com',
    iosClientId: '283635354027-3bpoac43auas5igmee9bk8hendqkfv5o.apps.googleusercontent.com',
    iosBundleId: 'com.thatexoticbug.escala',
  );
}