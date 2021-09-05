import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/helpers/database.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:latlong2/latlong.dart';

final bookmarkProvider =
    StateNotifierProvider<BookmarksController, List<Bookmark>>(
        (_) => BookmarksController());

class BookmarksController extends StateNotifier<List<Bookmark>> {
  BookmarksController() : super([]) {
    _loadBookmarks();
  }

  _loadBookmarks() async {
    state = await _getSavedBookmarks();
  }

  removeBookmark(Bookmark bookmark) {
    state = state.where((element) => element != bookmark).toList();
    if (bookmark.id != null)
      _deleteSavedBookmark(bookmark);
  }

  addBookmark(Bookmark bookmark) {
    state = [...state, bookmark];
    // This sets the "id" field of the bookmark.
    _addSavedBookmark(bookmark);
  }

  Future<List<Bookmark>> _getSavedBookmarks() async {
    final db = await DatabaseHelper.db.database;
    var bookmarks = await db.query(
      DatabaseHelper.BOOKMARKS,
      columns: ['id', 'name', 'lat', 'lon', 'emoji', 'created'],
    );
    return [for (var b in bookmarks) Bookmark.fromJson(b)];
  }

  Future<Bookmark> _addSavedBookmark(Bookmark bookmark) async {
    final db = await DatabaseHelper.db.database;
    bookmark.id = await db.insert(DatabaseHelper.BOOKMARKS, bookmark.toJson());
    return bookmark;
  }

  Future _deleteSavedBookmark(Bookmark bookmark) async {
    if (bookmark.id == null)
      throw Exception('Cannot delete bookmark ${bookmark.name} that does not have an id.');
    final db = await DatabaseHelper.db.database;
    await db.delete(DatabaseHelper.BOOKMARKS, where: 'id = ?', whereArgs: [bookmark.id]);
  }
}
