import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/providers/arrivals.dart';
import 'package:quick_bus/widgets/arrivals.dart';

class ArrivalsListContainer extends ConsumerWidget {
  final BusStop arrivalsStop;

  const ArrivalsListContainer(this.arrivalsStop);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () {
        return ref.refresh(multipleArrivalsProvider(arrivalsStop).future);
      },
      child: Consumer(
        builder: (context, watch, child) {
          final arrivalsValue =
              ref.watch(multipleArrivalsProvider(arrivalsStop));
          return arrivalsValue.when(
            data: (data) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                ref.read(arrivalsProviderCache(arrivalsStop).notifier).state =
                    data;
              });
              return data.isEmpty
                  ? Center(
                      child: Text(AppLocalizations.of(context)!.noArrivals,
                          style: kArrivalsMessageStyle),
                    )
                  : ArrivalsList(data);
            },
            loading: () {
              final cached =
                  ref.read(arrivalsProviderCache(arrivalsStop).notifier).state;
              if (cached.isNotEmpty) return ArrivalsList(cached);
              return Center(child: CircularProgressIndicator());
            },
            error: (e, stackTrace) => Center(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(AppLocalizations.of(context)!.arrivalsError,
                        textAlign: TextAlign.center,
                        style: kArrivalsMessageStyle),
                    SizedBox(height: 10.0),
                    Text(
                      e.toString(),
                      style: TextStyle(fontSize: 12.0),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(multipleArrivalsProvider(arrivalsStop));
                      },
                      child: Text(AppLocalizations.of(context)!.arrivalsTryAgain),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
