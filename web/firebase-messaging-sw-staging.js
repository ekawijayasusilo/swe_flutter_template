// FCM service worker for the staging flavor (project swe-flutter-template-staging).
// Config mirrors the `web` block in lib/firebase_options_staging.dart.
// SDK version must match firebase_core_web's supportedFirebaseJsSdkVersion; bump on firebase_core upgrades.
importScripts("https://www.gstatic.com/firebasejs/13.1.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/13.1.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCAGQLmWwQNPN6oYSuTWu_QNaQ09taSnZw",
  authDomain: "swe-flutter-template-staging.firebaseapp.com",
  projectId: "swe-flutter-template-staging",
  storageBucket: "swe-flutter-template-staging.firebasestorage.app",
  messagingSenderId: "552174566808",
  appId: "1:552174566808:web:84a0a34396627bdd00ffed",
});

// The SDK needs the messaging instance created to show background notifications.
firebase.messaging();
