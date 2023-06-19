import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../controllers/game.dart';

class Car extends SpriteComponent with CollisionCallbacks {
  double carHeight;
  double carWidth;
  double posX;
  double posY;
  String fileName;
  bool isPlayer;
  late ShapeHitbox hitbox;
  final _collisionStartColor = Colors.amber;
  final _defaultColor = Colors.cyan;

  Car({
    this.carHeight = 600,
    this.carWidth = 297,
    this.posX = 0,
    this.posY = 0,
    this.fileName = 'car1.png',
    this.isPlayer = true
  }) : super(
      size: Vector2(carWidth, carHeight),
      position: Vector2(posX, posY)
  );

  void moveUp(double delta) {
    y -= delta;
  }

  void moveDown(double delta) {
    y += delta;
  }

  void moveLeft(double delta) {
    x -= delta;
  }

  void moveRight(double delta) {
    x += delta;
  }

  @override
  Future<void> onLoad() async {
    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;
    hitbox = RectangleHitbox(size: Vector2(carWidth, carHeight))
      ..paint = defaultPaint
      ..renderShape = false;
    add(hitbox);
    sprite = await Sprite.load(fileName);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    if(!isPlayer) {
      return;
    }
    super.onCollisionStart(intersectionPoints, other);
    MyGame game =  super.findGame() as MyGame;
    game.stopGame();
  }
}