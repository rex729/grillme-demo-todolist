// 根據根目錄 google-services.json 與 GoogleService-Info.plist 自動產生的 Firebase 設定
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions 尚未設定 Web 平台，請於 Android 或 iOS 執行。',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions 不支援此平台: $defaultTargetPlatform',
        );
    }
  }

  // 對應 google-services.json (package_name: com.cullio.android)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD4fnuIEKqt3r0OEFgrjjnEokMDDF3faLQ',
    appId: '1:590561728933:android:3795c49cf19753f2e8f04c',
    messagingSenderId: '590561728933',
    projectId: 'cullio',
    storageBucket: 'cullio.firebasestorage.app',
  );

  // 對應 GoogleService-Info.plist (BUNDLE_ID: com.cullio)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBmyMq_2-Q0BTVRrR6336ScJxWoWKR6mLs',
    appId: '1:590561728933:ios:d82f6b86db510288e8f04c',
    messagingSenderId: '590561728933',
    projectId: 'cullio',
    storageBucket: 'cullio.firebasestorage.app',
    iosClientId:
        '590561728933-6cjm09g6jksp28nmmv8u3tpamjmhihef.apps.googleusercontent.com',
    iosBundleId: 'com.cullio',
  );
}
