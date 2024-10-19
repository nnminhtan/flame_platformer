class CustomHitbox {
  final double offsetX;
  final double offsetY;
  final double width;
  final double height;

  CustomHitbox(
      {required this.offsetX,
      required this.offsetY,
      required this.width,
      required this.height});

  // Factory method to create hitbox based on predefined object names
  factory CustomHitbox.fromPreset(String objectName) {
    switch (objectName) {
      case 'skeletonAttack1':
        return CustomHitbox(offsetX: 60, offsetY: 60, width: 50, height: 50);
      case 'Thorn':
        return CustomHitbox(offsetX: 4, offsetY: 4, width: 14, height: 10);
      case 'Spear':
        return CustomHitbox(offsetX: 4, offsetY: 4, width: 24, height: 24);
      // Add more cases for different objects
      case 'flyingeyeAttack1':
        return CustomHitbox(offsetX: 40, offsetY: 30, width: 20, height: 30);
      case 'mushroomAttack1':
        return CustomHitbox(offsetX: 38, offsetY: 33, width: 20, height: 30);
      case '':
      default:
        // Default hitbox if object name is not recognized
        return CustomHitbox(offsetX: 16, offsetY: 16, width: 32, height: 32);
    }
  }
}
