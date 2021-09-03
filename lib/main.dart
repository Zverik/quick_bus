import 'package:flutter/material.dart';
import 'package:quick_bus/screens/loading.dart';
import 'package:quick_bus/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

void main() {
  runApp(ProviderScope(child: QuickBusApp()));
}

class QuickBusApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('ee'),
        Locale('ru'),
      ],
      home: LoadingPage(),
    );
  }
}

