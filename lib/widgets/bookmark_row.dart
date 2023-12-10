import 'package:flutter/material.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:quick_bus/screens/search.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:reorderables/reorderables.dart';

class BookmarkRow extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final LatLng location;
  final bookmarkScrollController = ScrollController();
  final bool isPortrait;
  final Function(int, int) onReorder;

  BookmarkRow(this.location, this.bookmarks,
      {Orientation? orientation, required this.onReorder})
      : isPortrait = orientation == null || orientation == Orientation.portrait;

  @override
  Widget build(BuildContext context) {
    final bookmarkIcons = <Widget>[
      for (var bookmark in this.bookmarks)
        TextButton(
          key: ValueKey(bookmark.hashCode),
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
            semanticsLabel: bookmark.name,
            style: TextStyle(
              fontSize: 40.0,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
    ];

    final direction = isPortrait ? Axis.horizontal : Axis.vertical;
    final children = <Widget>[
      Expanded(
        flex: 100,
        // child: FadingEdgeScrollView.fromSingleChildScrollView(
        //   shouldDisposeScrollController: true,
        //   child: SingleChildScrollView(
        //     controller: bookmarkScrollController,
        //     scrollDirection: direction,
            child: isPortrait
                ? ReorderableRow(
                    children: bookmarkIcons,
                    onReorder: onReorder,
                    scrollController: bookmarkScrollController,
              draggingWidgetOpacity: 0.0,
                  )
                : ReorderableColumn(
                    children: bookmarkIcons, onReorder: onReorder),
          // ),
        // ),
      ),
      Spacer(),
      IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(location);
          }));
        },
        icon: Icon(Icons.search),
        tooltip: AppLocalizations.of(context)!.whereTo,
        iconSize: 40.0,
        color: Colors.black,
        // color: Theme.of(context).colorScheme.onPrimary,
      ),
    ];
    return Container(
      // color: Theme.of(context).colorScheme.primary,
      color: Colors.grey.shade300,
      child: Flex(direction: direction, children: children),
    );
  }
}
