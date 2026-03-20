class PlayerRanking {
  const PlayerRanking({
    required this.rank,
    required this.playerName,
    required this.monstersCaught,
  });

  final int rank;
  final String playerName;
  final int monstersCaught;

  factory PlayerRanking.fromJson(Map<String, dynamic> json, int index) {
    return PlayerRanking(
      rank: _parseInt(json['rank']) ?? index + 1,
      playerName: _parseString(
            json['player_name'] ?? json['playerName'] ?? json['name'],
          ) ??
          'Unknown Hunter',
      monstersCaught: _parseInt(
            json['monsters_caught'] ??
                json['monstersCaught'] ??
                json['score'] ??
                json['total'],
          ) ??
          0,
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

  static String? _parseString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
