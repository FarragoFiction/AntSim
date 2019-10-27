import 'dart:html';
import 'dart:typed_data';
import 'package:CommonLib/Random.dart';
import 'dart:math' as Math;

import 'World.dart';
class Citizen {
    String imageLocationLeft = "images/ballofsin.png";
    String imageLocationRight = "images/ballofsinRight.png";

    ImageElement imageLeft;
    ImageElement imageRight;
    CanvasElement canvasLeft;
    CanvasElement canvasRight;
    //in world coordinates, not screen coordinates
    int x;
    int y;
    int angle = 0;
    int runSpeed = 10;
    int digSpeed = 5;
    int size = 18;
    bool goRight = true;
    bool canDig = false;

    Citizen(int this.x, int this.y) {
        imageLeft = new ImageElement(src: imageLocationLeft);
        imageRight = new ImageElement(src: imageLocationRight);

    }

    void changeDirectionRandomly() {
        angle = new Random().nextIntRange(0,360);
        if(angle > 90 && angle < 270) {
            goRight = false;
        }else {
            goRight = true;
        }
    }

    //are you trying to walk into a wall? or out of bounds?
    bool canMove(int xgoal, int ygoal,CanvasElement dirtCanvas) {
        if(xgoal <size || xgoal > World.worldWidth-size) {
            return false;
        }
        if(ygoal <size || ygoal > World.worldWidth-size) {
            return false;
        }

        ImageData imgData = dirtCanvas.context2D.getImageData(xgoal, ygoal, (size/2).round(),size);
        Uint8ClampedList data = imgData.data; //Uint8ClampedList
        for(int i =0; i<data.length; i+=4) {
            if(data[i+3]> 200){
                return false;
            }
        }
        return true;
    }

    bool falling(CanvasElement dirtCanvas) {
        ImageData imgData = dirtCanvas.context2D.getImageData(x, y+size, size,size);
        Uint8ClampedList data = imgData.data; //Uint8ClampedList
        for(int i =0; i<data.length; i+=4) {
            if(data[i+3]> 200){
                return false;
            }
        }
        return true;
    }

    //TODO pheremone check for direction (and ability to put pheremones down)
    void move(CanvasElement dirtCanvas) {
        if(new Random().nextDouble() < 0.1) {
            changeDirectionRandomly();
        }
        int speed = canDig ? digSpeed: runSpeed;
        int xgoal = x+(Math.cos(angle* Math.pi/180)*speed).round();
        int ygoal = y+(Math.sin(angle*Math.pi/180)*speed).round();
        if(falling(dirtCanvas)) {
            ygoal = y + 10;
            xgoal = x;
        }else {
            digDirt(xgoal, ygoal, dirtCanvas);
        }

        if(canMove(xgoal,ygoal,dirtCanvas)){
            x = xgoal;
            y = ygoal;
        }else {
            changeDirectionRandomly();
        }
    }

    //TODO instead of clearing a rect, remove anything brown
    void digDirt(x,y,CanvasElement dirtCanvas) {
        int size = 20;
        if(canDig) dirtCanvas.context2D.clearRect(x,y,size, size);
    }

    CanvasElement initializeCanvas(ImageElement image) {
        CanvasElement canvas = new CanvasElement(width: image.width, height: image.width);
        image.onLoad.listen((Event e) {
            canvas.context2D.drawImage(image,0,0);
            if(canDig) {
                tintRed(canvas);
            }
        });
        return canvas;
    }

    void tintRed(CanvasElement canvas) {
      ImageData imgData = canvas.context2D.getImageData(
          0, 0, canvas.width, canvas.height);
      Uint8ClampedList data = imgData.data; //Uint8ClampedList
      for (int i = 0; i < data.length; i += 4) {
          data[i] = 255;
      }
      canvas.context2D.putImageData(imgData, 0,0);
    }

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas) {
        move(dirtCanvas);
        if(canvasLeft == null) {
            canvasLeft = initializeCanvas(imageLeft);
        }
        if(canvasRight == null) {
            canvasRight = initializeCanvas(imageRight);
        }
        goRight ? citizenCanvas.context2D.drawImage(canvasRight,x, y):citizenCanvas.context2D.drawImage(canvasLeft,x, y);
    }
}