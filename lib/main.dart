import 'package:flutter/material.dart';
import 'package:quick_bus/providers/language.dart';
import 'package:quick_bus/screens/loading.dart';
import 'package:quick_bus/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

void main() {
  runApp(ProviderScope(child: QuickBusApp()));
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

