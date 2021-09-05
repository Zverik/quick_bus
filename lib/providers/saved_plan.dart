import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/helpers/database.dart';
import 'package:quick_bus/models/route_element.dart';

final savedPlanProvider = StateNotifierProvider<SavedPlanController, SavedPlan>(
    (_) => SavedPlanController());

class SavedPlan {
  final List<RouteElement> itinerary;

  SavedPlan([this.itinerary = const []]);

  bool get isActive {
    if (itinerary.isEmpty) return false;
    final arrival = itinerary.last.arrival.add(Duration(minutes: 3));
    return arrival.isAfter(DateTime.now());
  }
}

class SavedPlanController extends StateNotifier<SavedPlan> {
  late Timer _timer;

  SavedPlanController() : super(SavedPlan()) {
    _loadItinerary().then((plan) {
      state = SavedPlan(plan ?? []);
    });
    _timer = Timer.periodic(Duration(seconds: 20), (_) {
      if (state.itinerary.isNotEmpty && !state.isActive) clearPlan();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void setPlan(List<RouteElement> plan) {
    state = SavedPlan(plan);
    _saveItinerary(plan);
  }

  void clearPlan() {
    setPlan([]);
  }

  Future _saveItinerary(List<RouteElement>? itinerary) async {
    final db = await DatabaseHelper.db.database;
    if (itinerary == null || itinerary.isEmpty) {
      await db.delete(DatabaseHelper.PLANS);
      return;
    }
    Map<String, dynamic> data = {
      'itinerary': jsonEncode([for (var i in itinerary) i.toJson()]),
      'arrival_on': itinerary.last.arrival.millisecondsSinceEpoch,
    };
    await db.delete(DatabaseHelper.PLANS);
    await db.insert(DatabaseHelper.PLANS, data);
  }

  Future<List<RouteElement>?> _loadItinerary() async {
    final db = await DatabaseHelper.db.database;
    var result = await db
        .query(DatabaseHelper.PLANS, columns: ['arrival_on', 'itinerary']);
    if (result.isEmpty) return null;
    var data = jsonDecode(result.first['itinerary'] as String);
    return [for (var element in data as List) RouteElement.fromJson(element)];
  }
}
