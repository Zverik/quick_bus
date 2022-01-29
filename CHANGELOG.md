# Easy Transit Tallinn Change Log

## 1.3.0

_Unreleased_

- Breaking: a route always starts from your position, not from the map center.
- Changed the marker when dragging the map to avoid misunderstanding.
- Bookmarks can no longer be dragged onto the map with a long tap.
  You can still plan a route somewhere and then reverse it.
- When choosing a destination on a map, tap to zoom to a location.
- For stops close by, arrival lists are merged with the current stop.
- After restoring the app, map location is reset to the user's position.
- Changed the icon for adding a bookmark.
- Itinerary is printed in two columns on tablets.
- For short walks an accurate distance is printed instead of zero meters.
- Made the blue location circle smaller.
- Reworked geolocation permissions requests.
- Upgraded the Riverpod library.

## 1.2.2

_Released for Android on 2021-01-22_

- Hiding obsolete arrival entries on the main screen.

## 1.2.1

_Released for iOS on 2021-01-16_

- Added a safe area so that a phone's notch does not obscure important text.
- Updated stops.

## 1.2.0

_Released on 2021-12-08_

- Added live vehicle locations to a route map.
- Route map is now zoomed on the current stop.
- Disabled labels by default on the route overview map.
- Not updating live arrivals for itineraries more than 15 minutes ahead.
- Displaying waiting time at a stop.
- Displaying walking time in a transfer.
- Arrival list updates do not hide the old state.
- Moved routing configuration to the server.

## 1.1.1

_Released on 2021-10-27_

- Enabled the search autocompletion.
- Arrivals list sometimes was not updated when following GPS location.
- Clarified the message when there are no stops around.
- "Delete bookmark" floating button was moved to the app bar.
- Added a button to reverse a route.
- Added a fourth tutorial page on changing a starting location.
- Updates the stops file (should be done for each release, but I forgot).

## 1.1.0

_Released on 2021-10-16_

- Renamed the app to "Easy Transit Tallinn".
- Updated Flutter to 2.5.2 and Dart to 2.14.3.
- Support for Android 12.
- Optional tutorial for the app.
- Back to a magnifier icon for searching.
- Added "activities" tab for bookmark emoji.
- Bookmark name is capitalized by default.
- You can now change a bookmark by deleting it and adding again.
- Disabled auto-focusing of the search input to prioritize last destinations.
- Reduced the number of last search queries shown.
- Search results keep their name when stored as last destinations.
- When tapping a search result, its title is displayed on the next page.
- Increased zoom level for map display of search results.
- Removed the redundant "coarse location" permission.
- Sometimes the arrivals list did not get updated after dragging the map.
- Removed subdomains from OSM tile URLs to improve caching.
- Map tiles are now cached to the internal memory.
- Fixed the landscape orientation for itineraries.
- **Known issue:** occasionally some itineraries fail to scroll, with
  out of memory errors logged. No idea yet what causes that — please
  rely on partial maps and general route descriptions for these.
  Currently observed on routes from Haabersti to "Pöhja öökull".

## 1.0.5

_Released on 2021-09-27_

- Arrivals are not updated when dragging a map now.
- Emoji picker when adding a bookmark was resetting itself constantly when typing.
- Location did not keep tracking GPS after pressing the tracking button.
- On the destination map, replaced a search button with a "my location" button.
- Enabled labels by default on the route overview map.

## 1.0.4

_Released on 2021-09-23_

- On the itinerary screen, draw a blue circle for the user's location.
- Hide itinerary legs that are in the past.
- After adding a bookmark, the route variant page is updated to reflect that.
- `LOCATION_NOT_ACCESSIBLE` OpenTripPlanner error is now translated.
- When scrolling too far from GPS location, show a bookmark to route back to you.

## 1.0.3

_Released on 2021-09-14_

- Added an item to the search panel to choose a destination on a map.
- Fixed an error when last destination became starting location.
- Searching failed when results contained an address.
- Search result type was made less prominent.
- OpenStreetMap attribution.
- Better default category and a label for the emoji picker.
- Added accessibility features.

## 1.0.2

_Released on 2021-09-10_

- Removed more debug code.
- Arrivals list no longer flickers when updating for the same stop.
- Changed destination icon from a magnifier to an arrow.
- Long press on a bookmark and drag it onto the map to use it
  for a starting location.
- Proper app icon masks.
- Changed arrivals fetching code to be more resilient, and forgiving to servers.
- Fixed an error in arrivals resulting in ignoring Siri response sometimes.

## 1.0.1

_Released on 2021-09-05_

- First beta testing version published to Play Store.
