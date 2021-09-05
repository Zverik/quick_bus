import 'package:sqflite/sqflite.dart';
import 'package:quick_bus/constants.dart';

class DatabaseHelper {
  static const String BOOKMARKS = 'bookmarks';
  static const String STOPS = 'stops';
  static const String ROUTES = 'routes';
  static const String DESTINATIONS = 'destinations';
  static const String PLANS = 'plans';
  static const String QUERIES = 'queries';

  DatabaseHelper._();
  static final DatabaseHelper db = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    if (_db == null) _db = await createDatabase();
    return _db!;
  }

  Future<Database> createDatabase() async {
    return await openDatabase(
      kDatabaseName,
      version: 4,
      onCreate: initDatabase,
      onUpgrade: upgradeDatabase,
    );
  }

  void initDatabase(Database database, int version) async {
    // For saving user destinations.
    await database.execute(
        "create table $BOOKMARKS (id integer primary key, lat real, lon real, name text, emoji text, created integer)");
    // For caching stops with siriId.
    await database.execute(
        "create table $STOPS (gtfsId text, siriId text, lat real, lon real, geohash text, name text, norm_name text)");
    // For caching OTP routes.
    await database.execute(
        "create table $ROUTES (otp_id text, number text, mode text, headsign text)");
    // Last searches
    await database.execute(
        "create table $DESTINATIONS (id integer primary key, lat real, lon real, name text, last_used integer)");
    // Bookmarked route plan
    await database
        .execute("create table $PLANS (itinerary text, arrival_on integer)");
    if (version >= 2) {
      // Search queries
      await database.execute(
          "create table $QUERIES (query text, last_used integer)");
    }
    if (version >= 3) {
      await database.execute("create index stops_geohash on $STOPS (geohash)");
    }
  }

  void upgradeDatabase(
      Database database, int oldVersion, int newVersion) async {
    print('Upgrading database from $oldVersion to $newVersion.');
    if (newVersion >= 2 && oldVersion < 2) {
      await database.execute("alter table $BOOKMARKS add emoji text");
      await database.execute("create table $QUERIES (query text, last_used integer)");
    }
    if (newVersion >= 3 && oldVersion < 3) {
      await database.execute("alter table $STOPS add geohash text");
      await database.execute("alter table $STOPS add norm_name text");
      await database.delete(STOPS);
      await database.execute("create index stops_geohash on $STOPS (geohash)");
    }
    if (newVersion >= 4 && oldVersion < 4) {
      await database.execute("alter table $DESTINATIONS add id integer");
    }
  }
}
