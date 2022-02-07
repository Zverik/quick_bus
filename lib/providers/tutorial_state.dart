import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seenTutorialProvider =
    StateNotifierProvider<SeenTutorialController, bool>(
        (_) => SeenTutorialController());

class SeenTutorialController extends StateNotifier<bool> {
  static const String TUTORIAL_DATE_KEY = "tutorial_date";

  SeenTutorialController() : super(true) {
    SharedPreferences.getInstance().then((preferences) {
      state = _seenTutorial(preferences.getInt(TUTORIAL_DATE_KEY));
    });
  }

  bool _seenTutorial(int? last) {
    final cutoff = DateTime.now().subtract(Duration(days: 1));
    return last != null && last < formatDate(cutoff);
  }

  setSeen() async {
    if (state) return;
    state = _seenTutorial(formatDate());
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(TUTORIAL_DATE_KEY, formatDate());
  }

  int formatDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
