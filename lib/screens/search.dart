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

class SearchPage extends StatefulWidget {
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

class _SearchPageState extends State<SearchPage> {
  List<SearchResult> results = [];
  List<SearchResult> geocoderResults = [];
  String query = '';
  String lastQuerySearchedForStops = '';
  final controller = TextEditingController();
  Timer? geocodeTimer;

  List<SearchResult> updateResults(ScopedReader watch, String query) {
    if (query.isEmpty) {
      lastQuerySearchedForStops = query;
      results = [
        SearchResult(
          icon: Icons.map,
          title: AppLocalizations.of(context)!.chooseOnMap,
          isMapItem: true,
        )
      ];
      final searchHistory = watch(searchHistoryProvider);
      for (var entry in searchHistory) {
        results.add(SearchResult(icon: Icons.history, title: entry.query));
      }
      final lastDest = watch(lastDestinationsProvider);
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
        final stopList = watch(stopsProvider);
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
    if (q.isEmpty) {
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
    if (geocodeTimer != null) geocodeTimer!.cancel();
    if (q.isEmpty) {
      setState(() {
        geocoderResults = [];
      });
      return;
    }
    geocodeTimer = Timer(Duration(milliseconds: 500), () async {
      geocodeTimer = null;
      doSearch(q);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            autofocus: true,
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
                final searchHistory =
                    context.read(searchHistoryProvider.notifier);
                searchHistory.saveQuery(value);
              }
              doSearch(value);
            },
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer(
          builder: (context, watch, child) {
            updateResults(watch, query);
            return ListView.separated(
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
                        final lastDestinations =
                            context.read(lastDestinationsProvider);
                        final destLoc = lastDestinations.isNotEmpty &&
                                lastDestinations.first.isRecent
                            ? lastDestinations.first.destination
                            : widget.start;
                        return DestinationPage(
                            start: widget.start, destination: destLoc);
                      }));
                    } else if (item.location != null) {
                      context
                          .read(lastDestinationsProvider.notifier)
                          .add(item.location!, item.title);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FindRoutePage(
                              start: widget.start,
                              end: item.location!,
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
                              );
                            }));
                          },
                          icon: Icon(Icons.map_outlined),
                          tooltip: AppLocalizations.of(context)?.showMap,
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
