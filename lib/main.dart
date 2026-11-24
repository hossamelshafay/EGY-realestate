import 'package:firebase_core/firebase_core.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/di/injection.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupDependencies();

  // SharedPreferences is registered by setupDependencies; retrieve it once
  // here so App can pass it to LocaleCubit without an async gap in the widget
  // tree.
  final prefs = await SharedPreferences.getInstance();

  runApp(App(prefs: prefs));
}
