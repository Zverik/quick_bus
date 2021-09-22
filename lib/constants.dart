import 'package:flutter/material.dart';

const kAppTitle = 'Quick Bus Tallinn';
const kDefaultLocation = <double>[59.42, 24.71];
const kDatabaseName = 'quickbus.db';
const kOTPEndpoint = 'otp.osmz.ru:8080';
const kPhotonEndpoint = 'otp.osmz.ru:2322';
const kSearchHistoryLength = 5;
const kMaxLatestDestinations = 5;
const kHideItineraryLegAfter = 2; // minutes after the next step started
const kPlanBefore = Duration(minutes: 2);
const kGeohashPrecision = 6; // ~600 meters
const kMinimumStopCount = 3000;
const kHostToPing = 'transport.tallinn.ee';
const kArrivalsMessageStyle = TextStyle(fontSize: 20.0);
const kRouteToSelfDistance = 1500; // meters