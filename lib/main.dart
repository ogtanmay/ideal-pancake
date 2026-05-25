import 'package:flutter/material.dart';

import 'src/core/di/service_locator.dart';
import 'src/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const OfflineAssistantApp());
}
