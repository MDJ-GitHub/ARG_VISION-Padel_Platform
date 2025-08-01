class Location {
  final int id;
  final bool archived;
  final String country;
  final String state;
  final String city;
  final String street;
  final double? latitude;
  final double? longitude;

  Location({
    required this.id,
    required this.archived,
    required this.country,
    required this.state,
    required this.city,
    required this.street,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      archived: json['archived'] ?? false,
      country: json['country'],
      state: json['state'],
      city: json['city'],
      street: json['street'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  @override
  String toString() {
    return '$street, $city, $state, $country';
  }
}

class Terrain {
  final int id;
  final bool archived;
  final String name;
  final String size;
  final double area;
  final int maxPlayers;
  final Location location;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? startTime;
  final String? endTime;
  final String? unavailableDays;
  final String? picture;

  Terrain({
    required this.id,
    required this.archived,
    required this.name,
    required this.size,
    required this.area,
    required this.maxPlayers,
    required this.location,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.startTime,
    this.endTime,
    this.unavailableDays,
    this.picture,
  });

  factory Terrain.fromJson(Map<String, dynamic> json) {
    return Terrain(
      id: json['id'],
      archived: json['archived'] ?? false,
      name: json['name'],
      size: json['size'] ?? 'M',
      area: json['area']?.toDouble() ?? 0.0,
      maxPlayers: json['max_players'] ?? 4,
      location: Location.fromJson(json['location']),
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      startTime: json['starttime'],
      endTime: json['endtime'],
      unavailableDays: json['unavailable_days'],
      picture: json['picture'],
    );
  }

  String get sizeDisplay {
    switch (size) {
      case 'S':
        return 'Small';
      case 'M':
        return 'Medium';
      case 'L':
        return 'Large';
      default:
        return 'Medium';
    }
  }

  @override
  String toString() {
    return '$name ($sizeDisplay)';
  }
}

class Position {
  final int id;
  final bool archived;
  final double x;
  final double y;
  final int terrainId;
  final String side;

  Position({
    required this.id,
    required this.archived,
    required this.x,
    required this.y,
    required this.terrainId,
    required this.side,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      archived: json['archived'] ?? false,
      x: json['x']?.toDouble() ?? 0.0,
      y: json['y']?.toDouble() ?? 0.0,
      terrainId: json['terrain'],
      side: json['side'] ?? 'A',
    );
  }

  String get sideDisplay {
    switch (side) {
      case 'A':
        return 'Side A';
      case 'B':
        return 'Side B';
      default:
        return 'Side A';
    }
  }

  @override
  String toString() {
    return 'Position ($x, $y) - $sideDisplay';
  }
}