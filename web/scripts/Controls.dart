import 'dart:async';
import 'dart:html';

import 'World.dart';

abstract class Controls {
    static  List<ButtonElement> modeButtons = new List<ButtonElement>();
    static ButtonElement leftButton;
    static ButtonElement rightButton;
    static ButtonElement upButton;
    static ButtonElement downButton;
    static String LEFT = "left";
    static String RIGHT = "right";
    static String UP = "up";
    static String DOWN = "down";


    static AudioElement soundEffects = new AudioElement();

    static bool cameraFiring = false;

    static void toggleMode(ButtonElement chosen) {
        modeButtons.forEach((ButtonElement b) => b.classes.remove("mode-selected"));
        chosen.classes.add("mode-selected");
    }

    static void toggleArrow(String direction) {
        String className = "mode-selected";
        leftButton.classes.remove(className);
        rightButton.classes.remove(className);
        upButton.classes.remove(className);
        downButton.classes.remove(className);
        if(direction == LEFT) leftButton.classes.add(className);
        if(direction == RIGHT) rightButton.classes.add(className);
        if(direction == UP) upButton.classes.add(className);
        if(direction == DOWN) downButton.classes.add(className);
    }

    static void generate(Element parent, World world) {
        DivElement container = new DivElement();
        parent.append(container);
        cameraControls(container, world);
        digButton(parent, world);
        dirtButton(parent,world);
        foodButton(parent,world);
        queenPheremoneButton(parent,world);
        enemyPheremoneButton(parent,world);
        foodPheremoneButton(parent,world);
        fileUpload(parent, world, parent);
    }

    static void cameraControls(DivElement container, World world) {
        leftCamera(container,world);
        rightCamera(container,world);
        upCamera(container,world);
        downCamera(container,world);
        wireUpKeyboard(world);
    }

    static wireUpKeyboard(world) {
        window.onKeyDown.listen((KeyboardEvent e){
            if(e.keyCode == KeyCode.LEFT) {
                toggleArrow(LEFT);
                world.moveCameraLeft();
            }else if(e.keyCode == KeyCode.RIGHT) {
                toggleArrow(RIGHT);
                world.moveCameraRight();
            }else if(e.keyCode == KeyCode.UP) {
                toggleArrow(UP);
                world.moveCameraUp();
            }else if(e.keyCode == KeyCode.DOWN) {
                toggleArrow(DOWN);
                world.moveCameraDown();
            }
        });

        window.onKeyUp.listen((KeyboardEvent e) {
            toggleArrow("none");
        });

        }

    static void leftCamera(DivElement container, World world) {
        leftButton = new ButtonElement()..text = "<";
        container.append(leftButton);

        window.onKeyUp.listen((Event e) {
            cameraFiring = false;
        });
        leftButton.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraLeft();
            keepFiring(world.moveCameraLeft);
            toggleArrow(LEFT);
        });
        leftButton.onMouseUp.listen((Event e) {
            cameraFiring = false;
            toggleArrow("none");
        });
    }

    static void rightCamera(DivElement container, World world) {
        rightButton = new ButtonElement()..text = ">";
        container.append(rightButton);
        rightButton.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraRight();
            keepFiring(world.moveCameraRight);
            toggleArrow(RIGHT);
        });
        rightButton.onMouseUp.listen((Event e) {
            cameraFiring = false;
            toggleArrow("none");
        });
    }

    static void upCamera(DivElement container, World world) {
        upButton = new ButtonElement()..text = "^";
        container.append(upButton);
        upButton.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraUp();
            keepFiring(world.moveCameraUp);
            toggleArrow(UP);
        });
        upButton.onMouseUp.listen((Event e) {
            cameraFiring = false;
            toggleArrow("none");
        });
    }

    static void downCamera(DivElement container, World world) {
        downButton = new ButtonElement()..text = "v";
        container.append(downButton);
        downButton.onMouseDown.listen((Event e) {
            cameraFiring = true;
            world.moveCameraDown();
            keepFiring(world.moveCameraDown);
            toggleArrow(DOWN);
        });
        downButton.onMouseUp.listen((Event e) {
            cameraFiring = false;
            toggleArrow("none");
        });
    }

    static void keepFiring(dynamic func) {
        if(!cameraFiring) return;
        func();
        new Timer(new Duration(milliseconds: 30), () => {
             keepFiring(func)
        });

    }

    static void enemyPheremoneButton(DivElement container, World world) {
        ButtonElement button = new ButtonElement()..text = "View Enemy Pheremones";
        container.append(button);
        button.onClick.listen((Event e) {
            world.viewEnemyPheremones = !world.viewEnemyPheremones;
            if(world.viewEnemyPheremones) {
                button.classes.add("mode-selected");
            }else {
                button.classes.remove("mode-selected");
            }
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