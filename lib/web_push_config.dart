// VAPID keys are single unbreakable tokens longer than 80 chars.
// ignore_for_file: lines_longer_than_80_chars

/// Web push settings for one flavor, passed to
/// `FirebaseMessaging.instance.register()` on web.
class WebPushConfig {
  const new({required this.vapidKey, required this.serviceWorkerPath});

  /// Public VAPID key: Firebase console > Project settings > Cloud Messaging >
  /// Web Push certificates. Public by design, safe to commit.
  final String vapidKey;

  /// Service worker file in `web/`, holding the same project's web config.
  final String serviceWorkerPath;
}

// Development and staging share the swe-flutter-template-staging project, so
// they use the same VAPID key.

const developmentWebPushConfig = WebPushConfig(
  vapidKey: 'BPMkXgAwnCZls0ysW49cuM51Nx6QyPoUDjL2Nmvel_p5x016ak_5Fj1I_bystH1bxTab7qxVIHQ8BJZChdPWQJY',
  serviceWorkerPath: 'firebase-messaging-sw-development.js',
);

const stagingWebPushConfig = WebPushConfig(
  vapidKey: 'BPMkXgAwnCZls0ysW49cuM51Nx6QyPoUDjL2Nmvel_p5x016ak_5Fj1I_bystH1bxTab7qxVIHQ8BJZChdPWQJY',
  serviceWorkerPath: 'firebase-messaging-sw-staging.js',
);

const productionWebPushConfig = WebPushConfig(
  vapidKey: 'BDJIGeSwzvFi3wjlUogpmrkCTARW348pH9sBZY-sFnLetp0PYN0FTKtp1CX6Gvqk9Ll6J7taNpWMB7ngFxhGYLU',
  serviceWorkerPath: 'firebase-messaging-sw-production.js',
);
