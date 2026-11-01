import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/providers/language.dart';

class LangSwitchButton extends ConsumerWidget {
  static const kFlags = <String, String>{
    'en': 'en',
    'et': 'et',
    'ru': 'ru',
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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          border: BoxBorder.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 5.0),
        child: Text(
          !kFlags.containsKey(lang) ? kUnknownFlag : kFlags[lang]!,
          style: TextStyle(fontSize: 24.0, color: Colors.white),
        ),
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
