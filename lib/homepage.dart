import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  final String title = "Highway Driver";
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int upperBoundX = 0, upperBoundY = 0, lowerBoundX = 0, lowerBoundY = 0;
  double screenWidth = 0, screenHeight = 0;
  double carWidth = 0, carHeight = 0;
  int padding = 0;
  List<double> lanePositions = [0, 0, 0];
  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    carHeight = 175;
    carWidth = 297*(carHeight/600);

    lowerBoundX = padding;
    lowerBoundY = padding;

    upperBoundX = screenWidth.toInt() - padding;
    upperBoundY = screenHeight.toInt() - padding;

    log("Dimensions: $screenWidth \t $screenHeight");

    lanePositions = [25, screenWidth/2 - carWidth/2, 280];

    for(int i=0; i<3; i++){
      log("${i}: ${lanePositions[i]}");
    }

    return Scaffold(
      body: Container(
        color: const Color(0xFF96FF96),
        child: Stack(
          children: [
            // Image(image: ResizeImage(
            //     const AssetImage("assets/road.png"),
            //     width: screenWidth.toInt() - 50,
            //     height: screenHeight.toInt() )),
            Image.asset("assets/road_with_stripes.png", width: screenWidth, height: screenHeight,),
            Positioned(
                bottom: 25,
                left: lanePositions[0],
                width: carWidth,
                height: carHeight,
                child: Stack(
                  children: [
                    Image.asset("assets/car1.png"),
                  ],
                )
            ),
            Positioned(
                bottom: 25,
                left: lanePositions[1],
                width: carWidth,
                height: carHeight,
                child: Stack(
                  children: [
                    Image.asset("assets/car2.png"),
                  ],
                )
            ),
            Positioned(
                bottom: 25,
                left: lanePositions[2],
                width: carWidth,
                height: carHeight,
                child: Stack(
                  children: [
                    Image.asset("assets/car3.png"),
                  ],
                )
            ),
          ],
        ),
      ),
    );
  }
}

// "assets/road.png", width: screenWidth, height: screenHeight