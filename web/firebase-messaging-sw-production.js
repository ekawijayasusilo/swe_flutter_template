// FCM service worker for the production flavor (project swe-flutter-template).
// Config mirrors the `web` block in lib/firebase_options_production.dart.
// SDK version must match firebase_core_web's supportedFirebaseJsSdkVersion; bump on firebase_core upgrades.
importScripts("https://www.gstatic.com/firebasejs/13.1.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/13.1.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBnufRhPX-QkOBwzN7PlidusKZ3OVMBQg8",
  authDomain: "swe-flutter-template.firebaseapp.com",
  projectId: "swe-flutter-template",
  storageBucket: "swe-flutter-template.firebasestorage.app",
  messagingSenderId: "44701027439",
  appId: "1:44701027439:web:56b29d534eccd308a3919a",
});

// The SDK needs the messaging instance created to show background notifications.
firebase.messaging();
