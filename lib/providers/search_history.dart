import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/helpers/database.dart';
import 'package:quick_bus/constants.dart';

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryController, List<SavedQuery>>(
        (_) => SearchHistoryController());

class SavedQuery {
  final String query;
  DateTime usedOn;

  SavedQuery(this.query, [DateTime? usedOn])
      : this.usedOn = usedOn ?? DateTime.now();

  factory SavedQuery.fromJson(json) => SavedQuery(
        json['query'],
        DateTime.fromMillisecondsSinceEpoch(json['last_used']),
      );

  Map<String, dynamic> toJson() => {
        'query': query,
        'last_used': usedOn.millisecondsSinceEpoch,
      };
}

class SearchHistoryController extends StateNotifier<List<SavedQuery>> {
  SearchHistoryController() : super([]) {
    _loadHistory();
  }

  _loadHistory() async {
    final db = await DatabaseHelper.db.database;
    final queries = await db.query(
      DatabaseHelper.QUERIES,
      columns: ['query', 'last_used'],
      limit: kSearchHistoryLength,
      orderBy: 'last_used desc',
    );
    state = [for (var q in queries) SavedQuery.fromJson(q)];
  }

  _saveQuery(SavedQuery query) async {
    final db = await DatabaseHelper.db.database;
    await db.insert(DatabaseHelper.QUERIES, query.toJson());
  }

  _updateQuery(SavedQuery query) async {
    final db = await DatabaseHelper.db.database;
    await db.update(
      DatabaseHelper.QUERIES,
      query.toJson(),
      where: 'query = ?',
      whereArgs: [query.query],
    );
  }

  _saveHistory() async {
    final db = await DatabaseHelper.db.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseHelper.QUERIES);
      for (var q in state) await txn.insert(DatabaseHelper.QUERIES, q.toJson());
    });
  }

  saveQuery(String query) {
    try {
      // If we have the query, raise it in the list.
      SavedQuery repeated =
          state.firstWhere((element) => element.query == query);
      repeated.usedOn = DateTime.now();
      _updateQuery(repeated);
      state.sort((a, b) => b.usedOn.compareTo(a.usedOn));
      state = state;
    } on StateError {
      var newList = [SavedQuery(query), ...state];
      if (newList.length > kSearchHistoryLength) {
        newList = newList.sublist(0, kSearchHistoryLength);
        _saveHistory();
      } else
        _saveQuery(newList.first);
      state = newList;
    }
  }
}
