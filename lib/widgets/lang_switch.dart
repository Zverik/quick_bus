import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/providers/language.dart';

class LangSwitchButton extends ConsumerWidget {
  static const kFlags = <String, String>{
    'en': '🇬🇧',
    'et': '🇪🇪',
    'ru': '🇷🇺',
  };
  static const kUnknownFlag = '🌐';

  const LangSwitchButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang =
        (ref.watch(languageProvider) ?? Localizations.localeOf(context))
            .languageCode;
    return TextButton(
      style: ButtonStyle(visualDensity: VisualDensity.compact),
      child: Text(
        !kFlags.containsKey(lang) ? kUnknownFlag : kFlags[lang]!,
        style: TextStyle(fontSize: 24.0),
      ),
      onPressed: () {
        final idx = kSupportedLocales.indexed
            .where((element) => element.$2.languageCode == lang)
            .firstOrNull
            ?.$1;
        final next = idx == null ? 0 : (idx + 1) % kSupportedLocales.length;
        ref.read(languageProvider.notifier).set(kSupportedLocales[next]);
      },
    );
  }
}
