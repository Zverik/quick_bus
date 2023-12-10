import 'package:quick_bus/helpers/log_store.dart';
import 'package:flutter/material.dart';

class LogDisplayPage extends StatefulWidget {
  const LogDisplayPage();

  @override
  State<LogDisplayPage> createState() => _LogDisplayPageState();
}

class _LogDisplayPageState extends State<LogDisplayPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('System Log')),
      body: SingleChildScrollView(
        controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(logStore.last(50).join('\n')),
        ),
      ),
    );
  }
}
