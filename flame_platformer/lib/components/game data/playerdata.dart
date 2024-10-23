class PlayerData {
  double hp;
  double x;
  double y;
  String level;
  String bonfireName;
  bool inCave;
  
  PlayerData({
    required this.x,
    required this.y,
    required this.hp,
    required this.level,
    required this.bonfireName,
    required this.inCave,
  });

  // Convert a GameData instance to a Map (for serialization)
  Map<String, dynamic> toJson() => {
        'hp': hp,
        'position': {'x': x, 'y': y},
        'level': level,
        'bonfireName': bonfireName,
        'inCave': inCave,
      };

  // Create a GameData instance from a Map (for deserialization)
  factory PlayerData.fromJson(Map<String, dynamic> json) {
    return PlayerData(
      hp: json['hp'],
      x: json['position']['x'],
      y: json['position']['y'],
      level: json['level'],
      bonfireName: json['bonfireName'],
      inCave: json['inCave'],
    );
  }
}
