import 'dart:developer';

import 'package:flutter/material.dart';
import './controllers/game.dart';
import 'package:flame/game.dart';

main() {
  final myGame = MyGame();
  runApp(
    GameWidget(
      game: myGame,
    ),
  );
}
