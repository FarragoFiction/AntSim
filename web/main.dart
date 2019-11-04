import 'dart:html';

import 'scripts/Citizen.dart';
import 'scripts/Controls.dart';
import 'scripts/World.dart';

void main() async{
  World world = new World();
  Controls.generate(querySelector("#output"), world);
  world.attachToScreen(querySelector("#output"));
  world.tick();
  //testMath(world);
}

void testMath(World world) {
  Citizen subject = world.citizens.first;
  print("Citizen is at ${subject.x}, ${subject.y}");
  int width = 1000;
  int upperRightX = 10;
  int upperRightY = 10;
  testPoint(subject, upperRightX, upperRightY, width, 45, "upperRight");

  int upperLeftX =  -10;
  int upperLeftY = upperRightY;
  testPoint(subject, upperLeftX, upperLeftY, width, 90+45, "upperLeft");


  int bottomRightX = upperRightX;
  int bottomRightY =  -10;
  testPoint(subject, bottomRightX, bottomRightY, width, -45, "bottomRight");

  int bottomLeftX = upperLeftX;
  int bottomLeftY = bottomRightY;
  testPoint(subject, bottomLeftX, bottomLeftY, width, -90-45, "bottomLeft");

}

void testPoint(Citizen subject, int testX, int testY, int width, int expectedAngle, label) {
  int index = subject.xyToIndex(testX,testY, width);
  print("$label: Given a coordinate of ${testX}, ${testY} and a width of ${width} I got an index of ${index}");
  print("$label If I try to invert this, I get an x of ${subject.iToX(index,width)} and a y of ${subject.iToY(index,width)}");
  int angle = subject.indexToAngle(index,width);
  print("$label the angle I get is: ${angle}, compared to expected of ${expectedAngle}");
  if(angle != expectedAngle) window.console.error("$label EMERGENCY!!! $angle is not $expectedAngle");
}
