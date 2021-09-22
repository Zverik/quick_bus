import 'package:flutter/material.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/helpers/equirectangular.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:quick_bus/screens/search.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class BookmarkRow extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final LatLng location;
  final LatLng? trackLocation;
  final bookmarkScrollController = ScrollController();
  final bool isPortrait;
  final VoidCallback? onStartDrag;
  final VoidCallback? onEndDrag;

  BookmarkRow(this.location, this.bookmarks,
      {Orientation? orientation, this.onStartDrag, this.onEndDrag, this.trackLocation})
      : isPortrait = orientation == null || orientation == Orientation.portrait;

  bool isFarEnough() {
    if (trackLocation == null)
      return false;
    final distance = DistanceEquirectangular();
    return distance(trackLocation!, location) > kRouteToSelfDistance;
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = trackLocation != null && isFarEnough() ? [Bookmark(
      name: AppLocalizations.of(context)!.myLocation,
      location: trackLocation!,
      emoji: '📍',
    ), ...this.bookmarks] : this.bookmarks;
    final bookmarkIcons = <Widget>[
      for (var bookmark in bookmarks)
        LongPressDraggable<Bookmark>(
          feedback: Text(
            bookmark.emoji,
            style: TextStyle(
              fontSize: 40.0,
              color: Theme.of(context).colorScheme.onPrimary,
              decoration: TextDecoration.none, // to remove yellow double underline
            ),
          ),
          data: bookmark,
          maxSimultaneousDrags: 1,
          onDragStarted: () {
            if (onStartDrag != null)
              onStartDrag!();
          },
          onDragEnd: (_) {
            if (onEndDrag != null)
              onEndDrag!();
          },
          child: TextButton(
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
        ),
    ];
    final children = <Widget>[
      Expanded(
        flex: 100,
        child: FadingEdgeScrollView.fromSingleChildScrollView(
          shouldDisposeScrollController: true,
          child: SingleChildScrollView(
            controller: bookmarkScrollController,
            scrollDirection: isPortrait ? Axis.horizontal : Axis.vertical,
            child: isPortrait
                ? Row(children: bookmarkIcons)
                : Column(children: bookmarkIcons),
          ),
        ),
      ),
      Spacer(),
      IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(location);
          }));
        },
        icon: Icon(Icons.arrow_forward),
        tooltip: AppLocalizations.of(context)!.whereTo,
        iconSize: 40.0,
        color: Colors.black,
        // color: Theme.of(context).colorScheme.onPrimary,
      ),
    ];
    return Container(
      // color: Theme.of(context).colorScheme.primary,
      color: Colors.grey.shade300,
      child: Flex(
          direction: isPortrait ? Axis.horizontal : Axis.vertical,
          children: children),
    );
  }
}
