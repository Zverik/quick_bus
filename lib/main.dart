import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_bus/helpers/log_store.dart';
import 'package:quick_bus/providers/language.dart';
import 'package:quick_bus/screens/loading.dart';
import 'package:quick_bus/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:logging/logging.dart';

void main() {
  const isRelease = bool.fromEnvironment('dart.vm.product');
  Logger.root.level = isRelease ? Level.WARNING : Level.INFO;
  Logger.root.onRecord.listen((event) {
    logStore.addFromLogger(event);
  });
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (details) {
      logStore.addFromFlutter(details);
      FlutterError.presentError(details);
    };
    runApp(ProviderScope(child: QuickBusApp()));
  }, (error, stack) {logStore.addFromZone(error, stack); });
}

class QuickBusApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: kAppTitle,
      // debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: kSupportedLocales,
      locale: ref.watch(languageProvider),
      home: LoadingPage(),
    );
  }
}
