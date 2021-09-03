import 'package:flutter/material.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/providers/last_dest.dart';
import 'package:quick_bus/screens/destination.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/screens/search.dart';

class BookmarkRow extends StatelessWidget {
  final List<Bookmark> bookmarks;
  final LatLng location;

  BookmarkRow(this.location, this.bookmarks);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Theme.of(context).colorScheme.primary,
      color: Colors.grey.shade300,
      child: Row(
        children: [
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
        ],
      ),
    );
  }
}
