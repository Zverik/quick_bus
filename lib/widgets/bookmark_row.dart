import 'package:flutter/material.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:quick_bus/screens/search.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class BookmarkRow extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final LatLng location;
  final bookmarkScrollController = ScrollController();

  BookmarkRow(this.location, this.bookmarks);

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final bookmarkIcons = <Widget>[
      for (var bookmark in bookmarks)
        TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FindRoutePage(
                    start: location,
                    end: bookmark.location,
                    bookmark: bookmark,
                  ),
                ));
          },
          child: Text(
            bookmark.emoji,
            style: TextStyle(
              fontSize: 40.0,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
    ];
    final children = <Widget>[
      Expanded(
        flex: 100,
        child: FadingEdgeScrollView.fromSingleChildScrollView(
          child: SingleChildScrollView(
            controller: bookmarkScrollController,
            scrollDirection: isPortrait ? Axis.horizontal : Axis.vertical,
            child: isPortrait ? Row(children: bookmarkIcons) : Column(children: bookmarkIcons),
          ),
        ),
      ),
      Expanded(child: Container()),
      IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(location);
          }));
        },
        icon: Icon(Icons.search),
        iconSize: 40.0,
        color: Colors.black,
        // color: Theme.of(context).colorScheme.onPrimary,
      ),
    ];
    return Container(
      // color: Theme.of(context).colorScheme.primary,
      color: Colors.grey.shade300,
      child: isPortrait ? Row(children: children) : Column(children: children),
    );
  }
}
