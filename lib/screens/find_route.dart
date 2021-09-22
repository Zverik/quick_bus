import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/route_query.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:quick_bus/providers/bookmarks.dart';
import 'package:quick_bus/screens/add_bookmark.dart';
import 'package:quick_bus/widgets/itinerary_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class FindRoutePage extends StatefulWidget {
  final Bookmark? bookmark;
  final LatLng start;
  final LatLng end;

  const FindRoutePage({required this.start, required this.end, this.bookmark});

  @override
  _FindRoutePageState createState() => _FindRoutePageState();
}

class _FindRoutePageState extends State<FindRoutePage> {
  List<List<RouteElement>>? options;
  String? errorMessage;
  Bookmark? bookmark;

  @override
  void initState() {
    super.initState();
    this.bookmark = widget.bookmark;
    findRoute();
  }

  void findRoute() async {
    try {
      var opts = await RouteQuery().getRouteOptions(widget.start, widget.end);
      setState(() {
        options = opts.where((element) => element.isNotEmpty).toList();
        errorMessage = null;
      });
    } on RouteQueryNetworkError catch (e) {
      setState(() {
        options = [];
        errorMessage = 'Network Error HTTP ${e.statusCode}';
      });
    } on RouteQueryOTPError catch (e) {
      setState(() {
        options = [];
        if (e.message == 'LOCATION_NOT_ACCESSIBLE')
          errorMessage = AppLocalizations.of(context)!.locationNotAccessible;
        else
          errorMessage = 'OpenTripPlanner error ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    Widget body;
    if (options == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: double.infinity),
          CircularProgressIndicator(value: null),
          SizedBox(height: 20.0),
          Text(
            loc.lookingForRoute,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      );
    } else if (errorMessage != null) {
      body = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );
    } else if (options!.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            loc.noRoutes,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
      );
    } else {
      body = ListView.separated(
        itemCount: options!.length,
        itemBuilder: (context, index) => ItineraryCard(options![index]),
        separatorBuilder: (context, index) => Divider(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(bookmark?.name ?? loc.newDestination),
      ),
      body: body,
      floatingActionButton: options == null || (bookmark != null && bookmark!.id == null)
          ? null
          : bookmark == null
              ? FloatingActionButton(
                  child: Icon(Icons.add),
                  tooltip: AppLocalizations.of(context)?.addBookmark,
                  onPressed: () async {
                    var bookmarkHelper =
                        context.read(bookmarkProvider.notifier);
                    Bookmark? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddBookmarkPage(widget.end),
                        ));
                    if (result != null) {
                      bookmarkHelper.addBookmark(result);
                      setState(() {
                        bookmark = result;
                      });
                    }
                  },
                )
              : FloatingActionButton(
                  child: Icon(Icons.delete),
                  tooltip: AppLocalizations.of(context)?.deleteBookmark(""),
                  onPressed: () async {
                    var bookmarkHelper =
                        context.read(bookmarkProvider.notifier);
                    OkCancelResult result = await showOkCancelAlertDialog(
                      context: context,
                      title: '${loc.delete}?',
                      message: loc.deleteBookmark(bookmark!.name),
                      okLabel: loc.delete,
                    );
                    if (result == OkCancelResult.ok) {
                      bookmarkHelper.removeBookmark(bookmark!);
                      Navigator.pop(context);
                      setState(() {
                        bookmark = null;
                      });
                    }
                  },
                ),
    );
  }
}
