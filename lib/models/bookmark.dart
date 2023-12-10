import 'package:latlong2/latlong.dart';

class Bookmark {
  int? id;
  final String name;
  final LatLng location;
  final String emoji;
  final DateTime createdOn;

  Bookmark({this.id, required this.name, required this.location, required this.emoji, DateTime? createdOn})
   : this.createdOn = createdOn ?? DateTime.now();

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      location: LatLng(json['lat'], json['lon']),
      createdOn: DateTime.fromMillisecondsSinceEpoch(json['created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'emoji': emoji,
      'lat': location.latitude,
      'lon': location.longitude,
      'created': createdOn.millisecondsSinceEpoch,
    };
  }

  @override
  int get hashCode => id ?? (emoji+name).hashCode;

  @override
  bool operator ==(Object other) {
    return other is Bookmark && id == other.id && name == other.name;
  }
}