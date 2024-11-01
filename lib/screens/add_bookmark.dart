import 'package:flutter/material.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:latlong2/latlong.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class AddBookmarkPage extends StatefulWidget {
  final LatLng location;

  AddBookmarkPage(this.location);

  @override
  _AddBookmarkPageState createState() => _AddBookmarkPageState();
}

class _AddBookmarkPageState extends State<AddBookmarkPage> {
  String name = "";
  String emoji = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addBookmark),
        actions: [
          IconButton(
            onPressed: name.isEmpty || emoji.isEmpty
                ? null
                : () {
                    final bookmark = Bookmark(
                      name: name,
                      location: widget.location,
                      emoji: emoji,
                    );
                    Navigator.pop(context, bookmark);
                  },
            icon: Icon(Icons.done),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60.0,
                    child: Text(emoji,
                        style: TextStyle(
                          fontSize: 40.0,
                        )),
                  ),
                  Expanded(
                    child: TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.bookmarkName,
                      ),
                      style: TextStyle(
                        fontSize: 20.0,
                      ),
                      // onChanged listener spews debug messages. It's okay.
                      // See https://github.com/flutter/flutter/issues/9471
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(left: 4.0),
              child: Text(
                AppLocalizations.of(context)!.chooseEmoji + ':',
                textAlign: TextAlign.start,
              ),
            ),
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    this.emoji = emoji.emoji;
                  });
                },
                config: const Config(
                  categoryViewConfig: CategoryViewConfig(
                    recentTabBehavior: RecentTabBehavior.NONE,
                    initCategory: Category.TRAVEL,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
