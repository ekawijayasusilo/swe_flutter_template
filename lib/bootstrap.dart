import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class AppBlocObserver extends BlocObserver {
  const new();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    if (!kIsWeb) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'bloc: ${bloc.runtimeType}',
        ),
      );
    }
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
  FirebaseOptions firebaseOptions,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Independent SDK inits run in parallel; add new ones to this list.
  await Future.wait([Firebase.initializeApp(options: firebaseOptions)]);

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
    // Crashlytics has no web SDK.
    if (!kIsWeb) {
      unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
    }
  };

  if (!kIsWeb) {
    // Keep local debug runs out of Crashlytics; profile/release still report.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode,
    );

    // Catches async errors thrown outside the Flutter framework.
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
      );
      return true;
    };
  }

  Bloc.observer = const AppBlocObserver();

  // Add cross-flavor configuration here

  runApp(await builder());
}
