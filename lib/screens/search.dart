import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/geocoder.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/providers/last_dest.dart';
import 'package:quick_bus/providers/search_history.dart';
import 'package:quick_bus/screens/destination.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:quick_bus/screens/log.dart';

class SearchPage extends ConsumerStatefulWidget {
  final LatLng start;

  SearchPage(this.start);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class SearchResult {
  final IconData icon;
  final String title;
  final String? address;
  final LatLng? location;
  final bool isMapItem;

  SearchResult({
    required this.icon,
    required this.title,
    this.location,
    this.address,
    this.isMapItem = false,
  });
}

class _SearchPageState extends ConsumerState<SearchPage> {
  List<SearchResult> results = [];
  List<SearchResult> geocoderResults = [];
  String query = '';
  String lastQuerySearchedForStops = '';
  final controller = TextEditingController();
  Timer? geocodeTimer;

  List<SearchResult> updateResults(String query) {
    if (query.isEmpty) {
      lastQuerySearchedForStops = query;
      results = [
        SearchResult(
          icon: Icons.map,
          title: AppLocalizations.of(context)!.chooseOnMap,
          isMapItem: true,
        )
      ];
      final searchHistory = ref.watch(searchHistoryProvider);
      for (var entry in searchHistory) {
        results.add(SearchResult(icon: Icons.history, title: entry.query));
      }
      final lastDest = ref.watch(lastDestinationsProvider);
      for (var dest in lastDest) {
        results.add(SearchResult(
          icon: Icons.location_history_rounded,
          title: dest.name,
          location: dest.destination,
        ));
      }
    } else {
      if (query.length < 2) {
        lastQuerySearchedForStops = query;
        results = [];
      } else if (query != lastQuerySearchedForStops) {
        lastQuerySearchedForStops = query;
        final stopList = ref.watch(stopsProvider);
        stopList
            .findStopsByName(query, around: widget.start, deduplicate: true)
            .then((stops) {
          if (mounted) {
            setState(() {
              results = [];
              for (var stop in stops) {
                results.add(SearchResult(
                  icon: Icons.directions_bus,
                  title: stop.name,
                  location: stop.location,
                ));
              }
            });
          }
        });
      }
    }
    return results;
  }

  doSearch(String q) async {
    cancelAutocomplete();
    if (q.length < 2) {
      geocoderResults = [];
      return;
    }
    var results = await AutocompleteGeocoder().query(q, widget.start);
    if (!mounted) return;
    setState(() {
      geocoderResults = [
        for (var r in results)
          SearchResult(
            icon: Icons.place,
            title: r.title,
            address: r.address,
            location: r.location,
          )
      ];
    });
  }

  autocompleteSearch(String q) {
    cancelAutocomplete();
    // Start geocoding 1 second after last key was typed.
    if (q.length >= 2) {
      geocodeTimer = Timer(Duration(milliseconds: 1000), () {
        geocodeTimer = null;
        doSearch(q);
      });
    }
  }

  cancelAutocomplete() {
    if (geocodeTimer != null) {
      geocodeTimer!.cancel();
      geocodeTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    updateResults(query);
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 40.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: TextField(
            // autofocus: true,
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: AppLocalizations.of(context)?.search ?? 'Search...',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.clear),
                tooltip: AppLocalizations.of(context)?.search,
                onPressed: () {
                  controller.clear();
                  setState(() {
                    query = '';
                    geocoderResults = [];
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                final searchHistory = ref.read(searchHistoryProvider.notifier);
                searchHistory.saveQuery(value);
              }
              doSearch(value);
            },
            onChanged: (value) {
              if (value == 'syslog') {
                controller.clear();
                value = '';
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => LogDisplayPage()));
                return;
              }
              setState(() {
                query = value;
              });
              if (value.length > 1) autocompleteSearch(value);
            },
          ),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          itemCount: results.length + geocoderResults.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final item = index < results.length
                ? results[index]
                : geocoderResults[index - results.length];
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: item.address == null ? null : Text(item.address!),
              onTap: () {
                if (item.isMapItem) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    final lastDestinations = ref.read(lastDestinationsProvider);
                    final destLoc = lastDestinations.isNotEmpty &&
                            lastDestinations.first.isRecent
                        ? lastDestinations.first.destination
                        : widget.start;
                    return DestinationPage(
                        start: widget.start, destination: destLoc);
                  }));
                } else if (item.location != null) {
                  ref
                      .read(lastDestinationsProvider.notifier)
                      .add(item.location!, item.title);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindRoutePage(
                          start: widget.start,
                          end: item.location!,
                          title: item.title,
                        ),
                      ));
                } else {
                  // This is a historic query
                  setState(() {
                    query = item.title;
                    controller.text = item.title;
                    doSearch(item.title);
                    FocusScope.of(context).unfocus();
                  });
                }
              },
              trailing: item.location == null
                  ? null
                  : IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return DestinationPage(
                            start: widget.start,
                            destination: item.location,
                            zoomCloser: true,
                          );
                        }));
                      },
                      icon: Icon(Icons.map_outlined),
                      tooltip: AppLocalizations.of(context)?.showMap,
                    ),
            );
          },
        ),
      ),
    );
  }
}
