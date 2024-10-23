import 'package:flame_platformer/components/game%20data/playerdata.dart';
import 'package:flame_platformer/components/game%20data/settingdata.dart';

class GameData {
  PlayerData playerData;
  SettingsData settingsData;

  GameData({
    required this.playerData,
    required this.settingsData,
  });

  // Convert GameData instance to Map (for JSON)
  Map<String, dynamic> toJson() => {
        'player': playerData.toJson(),
        'settings': settingsData.toJson(),
      };

  // Create a GameData instance from JSON
  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      playerData: PlayerData.fromJson(json['player']),
      settingsData: SettingsData.fromJson(json['settings']),
    );
  }
}
