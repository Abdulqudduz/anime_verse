import 'dart:async';
import 'dart:ui' as ui;

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart';
import 'package:inkino/message_provider.dart';
import 'package:inkino/ui/main_page.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized

  final prefs = await SharedPreferences.getInstance();
  final store =
      createStore(Client(), prefs); // Pass prefs instead of keyValueStore

  FinnkinoApi.useFinnish = ui.window.locale.languageCode == 'fi';

  runApp(InKinoApp(store));
}

final supportedLocales = const [
  Locale('en', 'US'),
  Locale('fi', 'FI'),
];

final localizationsDelegates = <LocalizationsDelegate>[
  const InKinoLocalizationsDelegate(),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
];

class InKinoApp extends StatefulWidget {
  const InKinoApp(this.store, {super.key});
  final Store<AppState> store;

  @override
  State<InKinoApp> createState() => _InKinoAppState();
}

class _InKinoAppState extends State<InKinoApp> {
  @override
  void initState() {
    super.initState();
    widget.store.dispatch(InitAction());
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: 'inKino',
        theme: ThemeData(
          primaryColor: const Color(0xFF1C306D),
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: const Color(0xFFFFAD32)),
          scaffoldBackgroundColor: Colors.transparent,
        ),
        home: const MainPage(),
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationsDelegates,
      ),
    );
  }
}
