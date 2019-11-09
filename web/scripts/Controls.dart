import 'dart:async';
import 'dart:html';

import 'World.dart';

abstract class Controls {
    static  List<ButtonElement> modeButtons = new List<ButtonElement>();
    static AudioElement soundEffects = new AudioElement();

    static bool cameraFiring = false;

    static void toggleMode(ButtonElement chosen) {
        modeButtons.forEach((ButtonElement b) => b.classes.remove("mode-selected"));
        chosen.classes.add("mode-selected");
    }

    static void generate(Element parent, World world) {
        DivElement container = new DivElement();
        parent.append(container);
        cameraControls(container, world);
        digButton(parent, world);
        dirtButton(parent,world);
        foodButton(parent,world);
        queenPheremoneButton(parent,world);
        foodPheremoneButton(parent,world);
        fileUpload(parent, world, parent);
    }

    static void cameraControls(DivElement container, World world) {
        leftCamera(container,world);
        rightCamera(container,world);
        upCamera(container,world);
        downCamera(container,world);
    }

    static void leftCamera(DivElement container, World world) {
        ButtonElement leftButton = new ButtonElement()..text = "<";
        container.append(leftButton);
        leftButton.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraLeft();
            keepFiring(world.moveCameraLeft);
        });
        leftButton.onMouseUp.listen((Event e) {
            cameraFiring = false;
        });
    }

    static void rightCamera(DivElement container, World world) {
        ButtonElement button = new ButtonElement()..text = ">";
        container.append(button);
        button.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraRight();
            keepFiring(world.moveCameraRight);
        });
        button.onMouseUp.listen((Event e) {
            cameraFiring = false;
        });
    }

    static void upCamera(DivElement container, World world) {
        ButtonElement button = new ButtonElement()..text = "^";
        container.append(button);
        button.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraUp();
            keepFiring(world.moveCameraUp);
        });
        button.onMouseUp.listen((Event e) {
            cameraFiring = false;
        });
    }

    static void downCamera(DivElement container, World world) {
        ButtonElement button = new ButtonElement()..text = "v";
        container.append(button);
        button.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraDown();
            keepFiring(world.moveCameraDown);
        });
        button.onMouseUp.listen((Event e) {
            cameraFiring = false;
        });
    }

    static void keepFiring(dynamic func) {
        if(!cameraFiring) return;
        func();
        new Timer(new Duration(milliseconds: 30), () => {
             keepFiring(func)
        });

    }

    static void queenPheremoneButton(DivElement container, World world) {
        ButtonElement button = new ButtonElement()..text = "View Queen Pheremones";
        container.append(button);
        button.onClick.listen((Event e) {
            world.viewQueenPheremones = !world.viewQueenPheremones;
            if(world.viewQueenPheremones) {
                button.classes.add("mode-selected");
            }else {
                button.classes.remove("mode-selected");
            }
        });
    }

    static void foodPheremoneButton(DivElement container, World world) {
        ButtonElement button = new ButtonElement()..text = "View Food Pheremones";
        container.append(button);
        button.onClick.listen((Event e) {
            world.viewFoodPheremones = !world.viewFoodPheremones;
            if(world.viewFoodPheremones) {
                button.classes.add("mode-selected");
            }else {
                button.classes.remove("mode-selected");
            }
        });
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