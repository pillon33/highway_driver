import 'dart:developer' as dev;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:highway_driver/windows/DialogWindow.dart';
import '../models/car.dart';
import '../models/road.dart';
import 'dart:math';
import '../buttons/DialogButton.dart';

class MyGame extends FlameGame with TapDetector, HorizontalDragDetector, HasCollisionDetection {
  // screen dimensions
  double screenWidth = 0;
  double screenHeight = 0;

  // car dimensions
  double ch = 0;
  double cw = 0;

  // x positions of lanes
  List<double> lanePositions = [0, 0, 0];

  // current player position
  int currentLine = 1;

  // player object
  Car player = Car();

  // obstacles
  List<Car> obstacles = [];

  // canvas
  Road road1 = Road();
  Road road2 = Road();
  Road road3 = Road();

  // movement parameters
  double velocity = 25;
  double verticalVelocity = 5;
  double timeSinceLastAcceleration = 0;
  double accelerationInterval = 5;
  double accelerationPower = 0.5;

  // score text
  TextPaint scoreTextPaint = TextPaint(style: const TextStyle(
      fontSize: 36,
      color: Color.fromRGBO(20,20,20, 1)
  ));
  Vector2 scoreTextPosition = Vector2(50, 50);
  double distanceTraveled = 0;
  SpriteComponent score = SpriteComponent();

  // game background
  @override
  Color backgroundColor() => const Color.fromRGBO(43, 43, 43, 1);

  // swipe distance
  double swipeDelta = 0;

  // obstacles parameters
  double spawnNextObstacle = 0;
  int numberOfObstacles = 0;
  int maxObstaclesNumber = 5;

  // game state menu - main menu, play - game in progress, over - game over
  String gameState = "menu";

  // ui buttons
  List<DialogButton> buttons = [];

  // dialog windows
  List<DialogWindow> activeWindows = [];

  @override
  Future<void> onLoad() async {
    // Initialize all parameters
    setParameters();

    // Initialize player instance
    loadPlayer();

    // Initialize instances of roads in background
    loadCanvas();

    // Render all objects
    await addObjects();

    await loadButtons();

    FlameAudio.bgm.play("soundtrack.mp3");
  }

  Future<void> loadButtons() async {
    switch (gameState) {
      case "menu":
        await mainMenu();
        break;

      case "over":
        await gameOver();
        break;
    }
  }

  void startGame() {
    removeAll(buttons);
    removeAll(obstacles);
    obstacles = [];
    buttons = [];

    setParameters();

    pauseButton();

    score.priority = 1;

    gameState = "play";
  }

  Future<void> help() async {
    removeAll(buttons);
    buttons = [];

    gameState = "help";

    DialogWindow window = DialogWindow(
        onClick: mainMenu,
        posX: screenWidth/2,
        posY: 100,
        content:
"""Welcome to Highway Driver
In this game your task is
to drive through highway 
and avoid collisions

Steering:
Tap/swipe right/left 
to switch line

That's it.
Nothing more.
Have fun."""
    )..priority = 1;

    await add(window);

    activeWindows.add(window);
  }

  Future<void> pause() async {
    removeAll(buttons);
    buttons = [];

    gameState = "pause";

    DialogWindow window = DialogWindow(
        onClick: continuePlaying,
        posX: screenWidth/2,
        posY: 100,
        content: """Game is paused""",
      title: "Pause",
      buttonFileName: "Button_play.png"
    )..priority = 1;

    await add(window);

    activeWindows.add(window);

  }

  Future<void> continuePlaying() async {
    // dispose dialog windows
    removeAll(activeWindows);
    activeWindows = [];

    gameState = "play";

    pauseButton();
  }

  Future<void> pauseButton() async {
    DialogButton pauseButton = DialogButton(
        w: 100,
        h: 100,
        posX: screenWidth - 120,
        posY: screenHeight - 120,
        onClick: pause,
        fileName: "Button_pause.png"
    )..priority = 1;
    await add(pauseButton);
    buttons.add(pauseButton);
  }

  Future<void> mainMenu() async {
    // dispose dialog windows
    removeAll(activeWindows);
    activeWindows = [];

    DialogButton startButton = DialogButton(
        w: 100,
        h: 100,
        posX: screenWidth/2 - 50,
        posY: screenHeight*2/7,
        onClick: startGame
    );
    await add(startButton);
    buttons.add(startButton);

    DialogButton helpButton = DialogButton(
        w: 100,
        h: 100,
        posX: screenWidth - 120,
        posY: screenHeight - 120,
        onClick: help,
        fileName: "Button_help.png"
    );
    await add(helpButton);
    buttons.add(helpButton);
  }

  Future<void> gameOver() async {
    //dispose all buttons
    removeAll(buttons);
    buttons = [];

    DialogButton button = DialogButton(
        w: 100,
        h: 100,
        posX: screenWidth/2 - 50,
        posY: screenHeight*2/7,
        fileName: "Button_retry.png",
        onClick: startGame
    );
    await add(button);
    buttons.add(button);

    DialogButton helpButton = DialogButton(
        w: 100,
        h: 100,
        posX: screenWidth - 120,
        posY: screenHeight - 120,
        onClick: help,
        fileName: "Button_help.png"
    );
    await add(helpButton);
    buttons.add(helpButton);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameState != "play") {
      return;
    }

    moveRoads();

    movePlayer();

    calculateScore();

    accelerate(dt);

    generateObstacle(dt);

    moveObstacles();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    scoreTextPaint.render(canvas, "${distanceTraveled.floor()}", scoreTextPosition);
  }

  void moveObstacles() {
    List<int> idxToRemove = [];
    for (Car obstacle in obstacles) {
      obstacle.moveDown(velocity);

      if(obstacle.y > screenHeight) {
        idxToRemove.add(obstacles.indexOf(obstacle));
        numberOfObstacles--;
      }
    }

    for (int idx in idxToRemove) {
      obstacles.removeAt(idx);
    }
  }

  // generates obstacles in random time intervals
  void generateObstacle(double dt) {
    if (spawnNextObstacle <= 0) {
      spawnNextObstacle = Random().nextInt(2) + 1;

      if (numberOfObstacles < maxObstaclesNumber) {
        spawnObstacle();
      }
    } else {
      spawnNextObstacle -= dt;
    }
  }

  void stopGame() {
    gameState = "over";

    loadButtons();
  }

  // spawns obstacles in random positions
  void spawnObstacle() {
    numberOfObstacles++;
    
    int lane = Random().nextInt(3);
    double posX = lanePositions[lane];
    double posY = -2*ch;
    int carNumber = Random().nextInt(5) + 1;
    String fileName = "car$carNumber.png";
    
    Car obstacle = Car(
        posY: posY,
        posX: posX,
        fileName: fileName,
        carWidth: cw,
        carHeight: ch,
        isPlayer: false
    );

    dev.log("adding obstacle");

    obstacles.add(obstacle);
    add(obstacle);
  }

  // Creates 3 instances of road
  void loadCanvas() {
    road1 = Road(
        screenHeight: screenHeight,
        screenWidth: screenWidth
    );

    road2 = Road(
        screenHeight: screenHeight,
        screenWidth: screenWidth
    );

    road3 = Road(
        screenHeight: screenHeight,
        screenWidth: screenWidth
    );

    road1.setPosition(0, 0);
    road2.setPosition(0, -0.8*screenHeight);
    road3.setPosition(0, -1.6*screenHeight);
  }

  // Creates player instance
  void loadPlayer() {
    player = Car(
        carHeight: ch,
        carWidth: cw,
        posX: lanePositions[currentLine],
        posY: screenHeight - ch - 30,
        fileName: 'car1.png'
    );
  }

  Future<void> addObjects() async {
    await add(road1);
    await add(road2);
    await add(road3);

    score = SpriteComponent(
        sprite: await Sprite.load("score.png"),
        size: Vector2(300, 100),
        position: Vector2(30, 20)
    )..priority = 1;
    await add(score);
    await add(player);
  }

  // Sets all parameters values
  void setParameters() {
    screenHeight = size[1];
    screenWidth = size[0];

    distanceTraveled = 0;

    ch = 200;
    cw = 297*(ch/600);

    lanePositions = [10, screenWidth/2 - cw/2, screenWidth - 10 - cw];
    currentLine = 1;
    player.x = lanePositions[currentLine];

    spawnNextObstacle = 2;
    numberOfObstacles = 0;
    maxObstaclesNumber = 5;

    velocity = 10;
    verticalVelocity = 10;
    timeSinceLastAcceleration = 0;
    accelerationInterval = 5;
    accelerationPower = 0.5;

    scoreTextPosition = Vector2(screenWidth/2 , 45);
  }

  // Updates distance value
  void calculateScore() {
    distanceTraveled += velocity/100;
  }

  // Increases velocity
  void accelerate(double dt) {
    timeSinceLastAcceleration += dt;

    if (timeSinceLastAcceleration >= accelerationInterval){
      velocity += accelerationPower;
      timeSinceLastAcceleration = 0;
    }
  }

  // Moves player vertically if he's switching lines
  void movePlayer() {
    double destination = lanePositions[currentLine];
    if (player.x != destination) {
      if(player.x < destination) {
        player.moveRight(verticalVelocity);

        if (player.x > destination) {
          player.x = destination;
        }
      } else {
        player.moveLeft(verticalVelocity);

        if (player.x < destination) {
          player.x = destination;
        }
      }
    }
  }

  // Moves canvas down to make driving impression
  void moveRoads() {
    road1.moveDown(velocity);
    road2.moveDown(velocity);
    road3.moveDown(velocity);

    if(road1.y + velocity > screenHeight){
      road1.setPosition(0, (-1.6)*screenHeight);
    }

    if(road2.y + velocity > screenHeight){
      road2.setPosition(0, (-1.6)*screenHeight);
    }

    if(road3.y + velocity > screenHeight){
      road3.setPosition(0, (-1.6)*screenHeight);
    }
  }

  // Steering behaviours

  @override
  void onTapUp(TapUpInfo info) {
    super.onTapUp(info);

    if (gameState != "play") {
      return;
    }

    Vector2 position = info.eventPosition.game;

    if (position.x > screenWidth/2 + screenWidth/10) {
      // Turn right
      if (currentLine < 2){
        currentLine++;
      }
    } else if (position.x < screenWidth/2 - screenWidth/10) {
      // Turn left
      if(currentLine > 0){
        currentLine--;
      }
    }
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    super.onHorizontalDragUpdate(info);

    if (gameState != "play") {
      return;
    }

    swipeDelta += info.delta.game.x;
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    super.onHorizontalDragEnd(info);

    if (gameState != "play") {
      return;
    }

    if (swipeDelta > screenWidth/10) {
      // Turn right
      if (currentLine < 2){
        currentLine++;
      }
    } else if (swipeDelta < -screenWidth/10) {
      // Turn left
      if(currentLine > 0){
        currentLine--;
      }
    }

    swipeDelta = 0;
  }
}