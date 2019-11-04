import 'dart:html';

import 'World.dart';

abstract class Controls {
    static  List<ButtonElement> modeButtons = new List<ButtonElement>();
    static AudioElement soundEffects = new AudioElement();

    static void toggleMode(ButtonElement chosen) {
        modeButtons.forEach((ButtonElement b) => b.classes.remove("mode-selected"));
        chosen.classes.add("mode-selected");
    }

    static void generate(Element parent, World world) {
        DivElement container = new DivElement();
        parent.append(container);
        digButton(container, world);
        dirtButton(container,world);
        foodButton(container,world);
        fileUpload(container, world, parent);
    }

    static void foodButton(DivElement container, World world) {
      ButtonElement foodButton = new ButtonElement()..text = "Food Mode";
      modeButtons.add(foodButton);
      container.append(foodButton);
      foodButton.onClick.listen((Event e) {
          world.mode = World.FOODMODE;
          toggleMode(foodButton);
      });
    }

    static void digButton(DivElement container, World world) {
       ButtonElement digButton = new ButtonElement()..text = "Dig Mode";
       toggleMode(digButton); //default
       modeButtons.add(digButton);
       container.append(digButton);
       digButton.onClick.listen((Event e) {
           world.mode = World.DIGMODE;
           toggleMode(digButton);
       });
    }

    static void dirtButton(DivElement container, World world) {
        ButtonElement digButton = new ButtonElement()..text = "Dirt Mode";
        modeButtons.add(digButton);
        container.append(digButton);
        digButton.onClick.listen((Event e) {
            world.mode = World.DIRTMODE;
            toggleMode(digButton);
        });
    }

    static void fileUpload(DivElement container, World world, Element parent) {
      InputElement fileElement = new InputElement();
      fileElement.type = "file";
      fileElement.classes.add("fileUploadButton");
      container.append(fileElement);
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
              world.attachToScreen(parent);
              world.tick();
          });
      });
    }

    static void playSoundEffect(String locationWithoutExtension) {
        if(soundEffects.canPlayType("audio/mpeg").isNotEmpty) soundEffects.src = "SoundFX/${locationWithoutExtension}.mp3";
        if(soundEffects.canPlayType("audio/ogg").isNotEmpty) soundEffects.src = "SoundFX/${locationWithoutExtension}.ogg";
        soundEffects.play();

    }
}