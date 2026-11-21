import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJwGIoKmtKsOsHal8-vUQ37DJNY5qPve0',
    appId: '1:308902872696:android:95e3e776a93b3f16798f8d',
    messagingSenderId: '308902872696',
    projectId: 'quizzbuzz-64752',
    authDomain: 'quizzbuzz-64752.firebaseapp.com',
    storageBucket: 'quizzbuzz-64752.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJwGIoKmtKsOsHal8-vUQ37DJNY5qPve0',
    appId: '1:308902872696:android:95e3e776a93b3f16798f8d',
    messagingSenderId: '308902872696',
    projectId: 'quizzbuzz-64752',
    storageBucket: 'quizzbuzz-64752.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCJwGIoKmtKsOsHal8-vUQ37DJNY5qPve0',
    appId: '1:308902872696:android:95e3e776a93b3f16798f8d',
    messagingSenderId: '308902872696',
    projectId: 'quizzbuzz-64752',
    storageBucket: 'quizzbuzz-64752.firebasestorage.app',
    iosBundleId: 'com.Buzzy.alto_quizz',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCJwGIoKmtKsOsHal8-vUQ37DJNY5qPve0',
    appId: '1:308902872696:android:95e3e776a93b3f16798f8d',
    messagingSenderId: '308902872696',
    projectId: 'quizzbuzz-64752',
    storageBucket: 'quizzbuzz-64752.firebasestorage.app',
    iosBundleId: 'com.Buzzy.alto_quizz',
  );
}
