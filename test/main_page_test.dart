import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:noted/app.dart';
import 'package:noted/providers/database.dart';
import 'package:noted/providers/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'path_provider_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Notes Tab Tests', () {
    Widget? app;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues(Map.fromIterable([]));
      PathProviderPlatform.instance = FakePathProviderPlatform();
      await Preferences.instance().load();
      if (Isar.getInstance() != null) return;
      await Isar.initializeIsarCore(download: true);
      await Database.instance().load();

      app = MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Preferences.instance()),
          ChangeNotifierProvider.value(value: Database.instance()),
        ],
        child: const App(),
      );
    });

    testWidgets('Note tab\'s FAB works', (tester) async {
      await tester.pumpWidget(app!);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(2));
    });

    tearDownAll(() async {
      if (Isar.getInstance() != null) {
        Isar.getInstance()!.close(deleteFromDisk: true);
      }
    });
  });
}
