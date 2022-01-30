import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final seenTutorialProvider =
    StateNotifierProvider<SeenTutorialController, bool>(
        (_) => SeenTutorialController());

class SeenTutorialController extends StateNotifier<bool> {
  static const String TUTORIAL_DATE_KEY = "tutorial_date";

  SeenTutorialController() : super(true) {
    SharedPreferences.getInstance().then((preferences) {
      _setSeen(preferences.getInt(TUTORIAL_DATE_KEY));
    });
  }

  _setSeen(int? last) {
    final cutoff = DateTime.now().subtract(Duration(days: 1));
    state = last != null && last < formatDate(cutoff);
  }

  setSeen() async {
    if (state) return;
    _setSeen(formatDate());
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(TUTORIAL_DATE_KEY, formatDate());
  }

  int formatDate([DateTime? date]) {
    final now = date ?? DateTime.now();
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
