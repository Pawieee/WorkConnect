// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyD6KnmptwyqvAHLgXTg4Oe66cc169h7c8w',
    appId: '1:541785312457:web:d4b599f563294859d51118',
    messagingSenderId: '541785312457',
    projectId: 'jobfindr-e5eb8',
    authDomain: 'jobfindr-e5eb8.firebaseapp.com',
    storageBucket: 'jobfindr-e5eb8.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5aCkqbUlGTlxNI9K6--aKaxx1kbuiSSU',
    appId: '1:541785312457:android:73dfbbd3bf96535cd51118',
    messagingSenderId: '541785312457',
    projectId: 'jobfindr-e5eb8',
    storageBucket: 'jobfindr-e5eb8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCF5znGnvTD5FJ4Dv767cZ4t9gtVqMK0eg',
    appId: '1:541785312457:ios:fe8b8562052a0b16d51118',
    messagingSenderId: '541785312457',
    projectId: 'jobfindr-e5eb8',
    storageBucket: 'jobfindr-e5eb8.firebasestorage.app',
    iosBundleId: 'com.3L1J.onlyJob',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCF5znGnvTD5FJ4Dv767cZ4t9gtVqMK0eg',
    appId: '1:541785312457:ios:fe8b8562052a0b16d51118',
    messagingSenderId: '541785312457',
    projectId: 'jobfindr-e5eb8',
    storageBucket: 'jobfindr-e5eb8.firebasestorage.app',
    iosBundleId: 'com.3L1J.onlyJob',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD6KnmptwyqvAHLgXTg4Oe66cc169h7c8w',
    appId: '1:541785312457:web:243cbae4cf0e9aa6d51118',
    messagingSenderId: '541785312457',
    projectId: 'jobfindr-e5eb8',
    authDomain: 'jobfindr-e5eb8.firebaseapp.com',
    storageBucket: 'jobfindr-e5eb8.firebasestorage.app',
  );
}
