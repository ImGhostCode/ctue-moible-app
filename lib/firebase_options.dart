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
    apiKey: 'AIzaSyAX_OFEEyAm8qUaIuk1yC2ydf_VuaC7unw',
    appId: '1:857454768302:web:177dcce284652e3d6bbd3f',
    messagingSenderId: '857454768302',
    projectId: 'ctue-mobile-app',
    authDomain: 'ctue-mobile-app.firebaseapp.com',
    storageBucket: 'ctue-mobile-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiliZVwjArRP8sl8U8P2Ow5Q04Yp5RE2I',
    appId: '1:857454768302:android:e4be79fbe165ab6c6bbd3f',
    messagingSenderId: '857454768302',
    projectId: 'ctue-mobile-app',
    storageBucket: 'ctue-mobile-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDFcJwMoKR0iomMTuahE2443zdws6zbkUg',
    appId: '1:857454768302:ios:c8a560b69b3d0b4c6bbd3f',
    messagingSenderId: '857454768302',
    projectId: 'ctue-mobile-app',
    storageBucket: 'ctue-mobile-app.appspot.com',
    iosBundleId: 'com.example.flutterMappCleanArchitecture',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDFcJwMoKR0iomMTuahE2443zdws6zbkUg',
    appId: '1:857454768302:ios:c8a560b69b3d0b4c6bbd3f',
    messagingSenderId: '857454768302',
    projectId: 'ctue-mobile-app',
    storageBucket: 'ctue-mobile-app.appspot.com',
    iosBundleId: 'com.example.flutterMappCleanArchitecture',
  );
}
