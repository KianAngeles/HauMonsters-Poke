class Monster {
  const Monster({
    required this.monsterId,
    required this.monsterName,
    required this.monsterType,
    required this.spawnLatitude,
    required this.spawnLongitude,
    required this.spawnRadiusMeters,
    required this.pictureUrl,
  });

  final int monsterId;
  final String monsterName;
  final String monsterType;
  final double spawnLatitude;
  final double spawnLongitude;
  final double spawnRadiusMeters;
  final String pictureUrl;

  bool get hasPicture => pictureUrl.trim().isNotEmpty;

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      monsterId: _parseInt(
            json['monster_id'] ??
                json['monsterId'] ??
                json['id'] ??
                json['monsterID'],
          ) ??
          0,
      monsterName: _parseString(
            json['monster_name'] ?? json['monsterName'] ?? json['name'],
          ) ??
          'Unknown Monster',
      monsterType: _parseString(
            json['monster_type'] ?? json['monsterType'] ?? json['type'],
          ) ??
          'Unknown Type',
      spawnLatitude: _parseDouble(
            json['spawn_latitude'] ??
                json['spawnLatitude'] ??
                json['latitude'] ??
                json['lat'],
          ) ??
          0,
      spawnLongitude: _parseDouble(
            json['spawn_longitude'] ??
                json['spawnLongitude'] ??
                json['longitude'] ??
                json['lng'] ??
                json['lon'],
          ) ??
          0,
      spawnRadiusMeters: _parseDouble(
            json['spawn_radius_meters'] ??
                json['spawnRadiusMeters'] ??
                json['spawn_radius'] ??
                json['radius_meters'] ??
                json['radius'],
          ) ??
          0,
      pictureUrl: _parseString(
            json['picture_url'] ??
                json['pictureUrl'] ??
                json['image_url'] ??
                json['imageUrl'] ??
                json['photo_url'] ??
                json['photoUrl'],
          ) ??
          '',
    );
  }

  Monster copyWith({
    int? monsterId,
    String? monsterName,
    String? monsterType,
    double? spawnLatitude,
    double? spawnLongitude,
    double? spawnRadiusMeters,
    String? pictureUrl,
  }) {
    return Monster(
      monsterId: monsterId ?? this.monsterId,
      monsterName: monsterName ?? this.monsterName,
      monsterType: monsterType ?? this.monsterType,
      spawnLatitude: spawnLatitude ?? this.spawnLatitude,
      spawnLongitude: spawnLongitude ?? this.spawnLongitude,
      spawnRadiusMeters: spawnRadiusMeters ?? this.spawnRadiusMeters,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString().trim());
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim());
  }

  static String? _parseString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
