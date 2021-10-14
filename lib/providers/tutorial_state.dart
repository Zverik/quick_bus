import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seenTutorialProvider = StateNotifierProvider<SeenTutorialController, bool>((_) => SeenTutorialController());

class SeenTutorialController extends StateNotifier<bool> {
  static const String SEEN_TUTORIAL_KEY = "seen_tutorial";

  SeenTutorialController() : super(true) {
    SharedPreferences.getInstance().then((preferences) {
      bool seenTutorial = preferences.getBool(SEEN_TUTORIAL_KEY) ?? false;
      if (seenTutorial != state) {
        state = seenTutorial;
      }
    });
  }

  setSeen() async {
    if (state) return;
    state = true;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(SEEN_TUTORIAL_KEY, true);
  }
}