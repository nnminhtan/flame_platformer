class SettingsData {
  double soundVolume;
  bool playSounds;

  SettingsData({required this.soundVolume, required this.playSounds});

  // Convert SettingsData instance to Map (for JSON)
  Map<String, dynamic> toJson() => {
        'soundVolume': soundVolume,
        'playSounds': playSounds,
      };

  // Create a SettingsData instance from JSON
  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      soundVolume: json['soundVolume'],
      playSounds: json['playSounds'],
    );
  }
}
