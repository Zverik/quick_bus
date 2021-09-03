/// Converts HTML-like tagged text to a series of TextSpans.
import 'dart:collection';

import 'package:flutter/material.dart';

final _kTagPattern = RegExp(r'<(/?)(\w+)>');
final _defaultTags = <String, TextStyle> {
  'b': TextStyle(fontWeight: FontWeight.bold),
  'i': TextStyle(fontStyle: FontStyle.italic),
};

class TagParsingError extends Error {
  final String message;
  TagParsingError(this.message);
}

List<TextSpan> parseTaggedText(String text, [Map<String, TextStyle> tags = const {}]) {
  if (text.isEmpty) return [];
  // Merge in default tags
  final tagMap = <String, TextStyle>{
    ..._defaultTags,
    ...tags,
  };
  List<TextSpan> spans = [];
  final styleStack = Queue<TextStyle>();
  final tagStack = Queue<String>();
  var match = _kTagPattern.firstMatch(text);
  while (match != null) {
    if (match.start > 0) {
      // Add text before the match
      spans.add(TextSpan(
        text: text
            .substring(0, match.start)
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&amp;', '&'),
        style: styleStack.isEmpty ? null : styleStack.last,
      ));
    }
    final String tag = match.group(2)!;
    if (match.group(1)!.isNotEmpty) {
      // Closing last tag
      if (tagStack.isEmpty || tagStack.last != tag)
        throw TagParsingError('Unexpected closing tag </$tag>');
      tagStack.removeLast();
      styleStack.removeLast();
    } else {
      // New tag
      if (!tagMap.containsKey(tag))
        throw TagParsingError('Unknown tag <$tag>');
      tagStack.addLast(tag);
      final style = tagMap[tag]!;
      final newStyle = styleStack.isEmpty ? style : styleStack.last.merge(style);
      styleStack.addLast(newStyle);
    }
    text = text.substring(match.end);
    match = _kTagPattern.firstMatch(text);
  }
  spans.add(TextSpan(
    text: text
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&'),
    style: styleStack.isEmpty ? null : styleStack.last,
  ));
  return spans;
}
