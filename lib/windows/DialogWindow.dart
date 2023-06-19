import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../buttons/DialogButton.dart';

class DialogWindow extends SpriteComponent {
  double h;
  double w;
  double posX;
  double posY;
  String fileName;
  String buttonFileName;
  String title;
  String content;
  Function onClick;
  List<DialogButton> buttons = [];

  DialogWindow({
    this.h = 500,
    this.w = 350,
    this.posX = 0,
    this.posY = 0,
    this.fileName = 'Window_12.png',
    this.title = "Hello",
    this.content = "World",
    this.buttonFileName = "Button_exit.png",
    required this.onClick
  }) : super(
      size: Vector2(w, h),
      position: Vector2(posX, posY),
      anchor: Anchor.topCenter
  );

  // title text
  TextPaint titleTextPaint = TextPaint(style: const TextStyle(
      fontSize: 36,
      color: Color.fromRGBO(220,220,220, 1)
  ));
  Vector2 titleTextPosition = Vector2(50, 50);

  // title text
  TextPaint contentTextPaint = TextPaint(style: const TextStyle(
      fontSize: 18,
      color: Color.fromRGBO(20,20,20, 1)
  ));
  Vector2 contentTextPosition = Vector2(200, 200);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(fileName);

    titleTextPosition = Vector2(posX - 20, posY - 90);
    contentTextPosition = Vector2(posX - 20, posY + 5);

    DialogButton okButton = DialogButton(
      onClick: _onClick,
      fileName: buttonFileName,
      posY: posY + h - 170,
      posX: posX - 70
    );

    await add(okButton);
    buttons.add(okButton);
  }

  void _onClick() {
    removeAll(buttons);
    onClick();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    titleTextPaint.render(canvas, title , titleTextPosition, anchor: Anchor.topCenter);

    contentTextPaint.render(canvas, content , contentTextPosition, anchor: Anchor.topCenter);
  }
}