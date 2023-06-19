import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class DialogButton extends SpriteComponent with TapCallbacks {
  double h;
  double w;
  double posX;
  double posY;
  String fileName;
  Function onClick;

  DialogButton({
    this.h = 100,
    this.w = 100,
    this.posX = 0,
    this.posY = 0,
    this.fileName = 'Button_play.png',
    required this.onClick
  }) : super(
      size: Vector2(w, h),
      position: Vector2(posX, posY)
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(fileName);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    onClick();
  }
}