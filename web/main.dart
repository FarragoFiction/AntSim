import 'dart:html';

import 'scripts/Citizen.dart';
import 'scripts/World.dart';

void main() async{
  World world = new World();

  InputElement fileElement = new InputElement();
  fileElement.type = "file";
  fileElement.classes.add("fileUploadButton");
  querySelector("#output").append(fileElement);
  fileElement.onChange.listen((Event e) {
    List<File> loadFiles = fileElement.files;
    File file = loadFiles.first;
    FileReader reader = new FileReader();
    reader.readAsDataUrl(file);
    print("the file was $file");
    reader.onLoadEnd.listen((e) {
      world.teardown();

      //sparse
      String loadData = reader.result;
      //String old = chat.icon.src;
      world = new World();
      world.dirt = new ImageElement();
      world.dirt.src = loadData;
      world.attachToScreen(querySelector("#output"));
      world.tick();
    });
  });
  world.attachToScreen(querySelector("#output"));
  world.tick();
  //testMath(world);
}

void testMath(World world) {
  Citizen subject = world.citizens.first;
  print("Citizen is at ${subject.x}, ${subject.y}");
  int width = 1000;
  int upperRightX = subject.x+10;
  int upperRightY = subject.y+10;
  testPoint(subject, upperRightX, upperRightY, width, 45);

  int upperLeftX = subject.x -10;
  int upperLeftY = upperRightY;
  testPoint(subject, upperLeftX, upperLeftY, width, 90+45);


  int bottomRightX = upperRightX;
  int bottomRightY = subject.y -10;
  testPoint(subject, bottomRightX, bottomRightY, width, 180+45);

  int bottomLeftX = upperLeftX;
  int bottomLeftY = bottomRightY;
  testPoint(subject, bottomLeftX, bottomLeftY, width, 270+45);

}

void testPoint(Citizen subject, int testX, int testY, int width, int expectedAngle) {
  int index = subject.xyToIndex(testX,testY, width);
  print("Given a coordinate of ${testX}, ${testY} and a width of ${width} I got an index of ${index}");
  print("If I try to invert this, I get an x of ${subject.iToX(index,width)} and a y of ${subject.iToY(index,width)}");
  int angle = subject.indexToAngle(index,width);
  print("the angle I get is: ${angle}, compared to expected of ${expectedAngle}");
  if(angle != expectedAngle) window.console.error("EMERGENCY!!! $angle is not $expectedAngle");
}
