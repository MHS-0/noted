import 'package:flutter/material.dart';
import 'package:noted/app.dart';
import 'package:noted/providers/preferences.dart';
import 'package:noted/providers/database.dart';
import 'package:provider/provider.dart';

/// Initializes the needed instances and providers, and launches the app.
///
/// Calling [WidgetsFlutterBinding.ensureInitialized] is needed for loading SharedPreferences
/// and Isar Database instances before calling [runApp].
/// These two instances containing our users data will be loaded by calling the load method (make sure
/// to await them as they make asynchronous calls).
///
/// The [Preferences] provider manages the SharedPreferences instance, and the [Database] provider
/// manages an Isar instance internally. We can only have one instance of them which we get by calling
/// the instance methods of them.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Preferences.instance().load();
  await Database.instance().load();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Preferences.instance()),
        ChangeNotifierProvider.value(value: Database.instance()),
      ],
      child: const App(),
    ),
  );
}
