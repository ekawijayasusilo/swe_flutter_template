import 'package:swe_flutter_template/app/app.dart';
import 'package:swe_flutter_template/bootstrap.dart';
import 'package:swe_flutter_template/firebase_options_production.dart';

Future<void> main() async {
  await bootstrap(() => const App(), DefaultFirebaseOptions.currentPlatform);
}
