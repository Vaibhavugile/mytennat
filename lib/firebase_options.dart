// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get web => const FirebaseOptions(
    apiKey: "AIzaSyB2lp_ladV4I4KF2s8-DvCntXuxRLAI2EI",
    authDomain: "mytennat.firebaseapp.com",
    projectId: "mytennat",
    storageBucket: "mytennat.firebasestorage.app",
    messagingSenderId: "984950929715",
    appId: "1:984950929715:web:604b1209054b6327166646",
    measurementId: "G-T6PDN1PWSK",
  );

  static FirebaseOptions get android => const FirebaseOptions(
    apiKey: "AIzaSyB2lp_ladV4I4KF2s8-DvCntXuxRLAI2EI", // use the same unless Android has separate API key
    appId: "1:984950929715:android:1:984950929715:android:d733677447d6e305166646", // UPDATE THIS from Firebase Console
    messagingSenderId: "984950929715",
    projectId: "mytennat",
    storageBucket: "mytennat.firebasestorage.app",
  );
}
