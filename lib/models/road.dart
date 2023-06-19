import 'package:flame/components.dart';

class Road extends SpriteComponent {
  double screenHeight;
  double screenWidth;
  Road({
    this.screenHeight = 600,
    this.screenWidth = 400
  }) : super(
      size: Vector2(screenWidth, screenHeight)
  );

  void moveUp(double delta) {
    y -= delta;
  }

  void moveDown(double delta) {
    y += delta;
  }

  void setPosition(double posX, double posY) {
    x = posX;
    y = posY;
  }

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('road_with_stripes.png');
  }
}