import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:quick_bus/constants.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

Future showNoInternetDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return NoInternetPage();
    },
  );
}

class NoInternetPage extends StatefulWidget {
  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
        await http
            .get(Uri.http(kHostToPing, '/'))
            .timeout(Duration(seconds: 2));
        timer.cancel();
        Navigator.pop(context);
      } on TimeoutException {
        // timeout
      } on SocketException {
        // socket error
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = Dialog(
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.enableInternet,
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
    return body;
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
      ),
      body: body,
    );
  }
}
