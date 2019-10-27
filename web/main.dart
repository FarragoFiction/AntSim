import 'dart:html';

import 'scripts/World.dart';

void main() async{
  World world = new World();
  world.attachToScreen(querySelector("#output"));
  world.tick();
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
}
