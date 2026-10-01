// File generated for Firebase initialization
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your BookWorm application.
///
/// If you have configured a custom Firebase project with `flutterfire configure`,
/// your generated keys will seamlessly plug in here.
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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfE31ZS_HDIs6aDb7ewrhCpoGIAc7XAP8',
    appId: '1:940668782958:web:e7fea9a9f1b6f4bdfe997f',
    messagingSenderId: '940668782958',
    projectId: 'bookworm-platform',
    authDomain: 'bookworm-platform.firebaseapp.com',
    databaseURL: 'https://bookworm-platform-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'bookworm-platform.firebasestorage.app',
    measurementId: 'G-DKDN1L08TJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC7R456wGJSGgSkMYDtJ-pKmJuWFrW_k64',
    appId: '1:940668782958:android:4a5c5c83b093d864fe997f',
    messagingSenderId: '940668782958',
    projectId: 'bookworm-platform',
    databaseURL: 'https://bookworm-platform-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'bookworm-platform.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBookWormIosDemoApiKeyPlaceholder2026',
    appId: '1:102938475610:ios:abcdef1234567890',
    messagingSenderId: '102938475610',
    projectId: 'bookworm-sanctuary',
    storageBucket: 'bookworm-sanctuary.appspot.com',
    iosBundleId: 'com.bookworm.bookWorm',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBookWormMacosDemoApiKeyPlaceholder2026',
    appId: '1:102938475610:ios:abcdef1234567890',
    messagingSenderId: '102938475610',
    projectId: 'bookworm-sanctuary',
    storageBucket: 'bookworm-sanctuary.appspot.com',
    iosBundleId: 'com.bookworm.bookWorm',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBookWormWindowsDemoApiKeyPlaceholder',
    appId: '1:102938475610:web:abcdef1234567890',
    messagingSenderId: '102938475610',
    projectId: 'bookworm-sanctuary',
    storageBucket: 'bookworm-sanctuary.appspot.com',
  );
}
