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
    //eventually you retire, no infini digging plz
    int chunksDug = 0;
    int maxChunks = 333;
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

    int xyToIndex(int x2, int y2, int width) {
        return y2*width + x2;
    }

    int indexToAngle(int index, int width) {
        int x2 = iToX(index, width);
        int y2 = iToY(index,width);
        print("x is 0, x2 is $x2");
        print("y is 0, y2 is $y2");
        print("so atan2 would be ${Math.atan2(y2, x2)} and converted to degrees thats ${((180/Math.pi)*Math.atan2(y2, x2)).round()} ");
        return ((180/Math.pi)*Math.atan2(y2, x2)).round();
    }
    //if i'm at i = 13 of a 10 wide image
    //then my x coordinate is 3, and my y coordinate is 1
    // or i%10 and i/10 respectively
    int iToX(int i, int width) {
        if(i<0) window.console.error("Why is the index negative ($i) in inToX?");
        return i % width;
    }

    int iToY(int i, int width) {
        return (i / width).floor();
    }


    //returns if relevant pheremone was detected enough to change directions
    //we aren't going for perfect here, just fast. ants detect a SQUARE around themselves, not a circle.
    //deal with it.
    bool considerPheremones(CanvasElement queenPheremoneCanvas) {
        //todo seperate this out to consider queen pheremones, once there are other layers
        int width = size*2;
        ImageData imgData = queenPheremoneCanvas.context2D.getImageData((x-size/2).round(), (y+size/2).round(), size,size);
        Uint8ClampedList data = imgData.data; //Uint8ClampedList
        int max = 0;
        List<int> possibleIndices = new List<int>();
        //TODO if this is too slow just randomly sample a few
        for(int i =0; i<data.length; i+=4) {
            if(data[i+3]>= max){

                if(max != data[i+3]) {
                    possibleIndices.clear();
                    max = data[i+3];
                }
                possibleIndices.add(i);
            }
        }
        if(max == 0 || possibleIndices.isEmpty) return false;
        int index = new Random().pickFrom(possibleIndices);
        if(index == null) return false;
        angle = indexToAngle(index, width);
        if(canDig) print("angle is $angle with max of $max");
        return true;
    }

    //TODO pheremone check for direction (and ability to put pheremones down)
    void move(CanvasElement dirtCanvas, CanvasElement queenPheremoneCanvas, [bool secondTry = false]) {
        bool foundPheremone = considerPheremones(queenPheremoneCanvas);

        if(secondTry || (!foundPheremone && new Random().nextDouble() < 0.1)) {
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
            //try to move again, but ignore ai
            if(!secondTry) move(dirtCanvas,queenPheremoneCanvas,true);
        }
    }

    //TODO instead of clearing a rect, remove anything brown
    void digDirt(x,y,CanvasElement dirtCanvas) {
        int size = 20;
        if(canDig) {
            dirtCanvas.context2D.clearRect(x, y, size, size);
            chunksDug ++;
            if(chunksDug >maxChunks) {
                canDig = false;
                initializeSprites();
            }
        }
    }

    CanvasElement initializeCanvas(ImageElement image) {
        int width = image.width;
        if(width == null || width == 0) width = 18;
        CanvasElement canvas = new CanvasElement(width: width, height: width);
        if(image.width != 0) {
            canvas.context2D.drawImage(image,0,0);
            if(canDig) {
                tintRed(canvas);
            }
        }
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

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas, CanvasElement queenPheremoneCanvas) {
        move(dirtCanvas,queenPheremoneCanvas);
        if(canvasLeft == null || canvasRight == null) initializeSprites();
        goRight ? citizenCanvas.context2D.drawImage(canvasRight,x, y):citizenCanvas.context2D.drawImage(canvasLeft,x, y);
    }

    void initializeSprites() {
          canvasLeft = initializeCanvas(imageLeft);
          canvasRight = initializeCanvas(imageRight);
    }
}