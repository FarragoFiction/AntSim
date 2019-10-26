import 'dart:html';
import 'dart:typed_data';
import 'package:CommonLib/Random.dart';
import 'dart:math' as Math;
class Citizen {
    String imageLocationLeft = "images/ballofsin.png";
    String imageLocationRight = "images/ballofsinRight.png";

    ImageElement imageLeft;
    ImageElement imageRight;
    //in world coordinates, not screen coordinates
    int x;
    int y;
    int angle = 0;
    int speed = 10;
    int size = 18;
    bool goRight = true;
    bool canDig = false;
    //if falling can't choose to move till you are no longer falling
    bool falling = false;

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

    //are you trying to walk into a wall?
    bool canMove(int xgoal, int ygoal,CanvasElement dirtCanvas) {
        ImageData imgData = dirtCanvas.context2D.getImageData(xgoal, ygoal, (size/2).round(),size);
        Uint8ClampedList data = imgData.data; //Uint8ClampedList
        for(int i =0; i<data.length; i+=4) {
            if(data[i+3]> 200){
                return false;
            }
        }
        return true;
    }

    void move(CanvasElement dirtCanvas) {
        //TODO check if you're falling first.
        if(new Random().nextDouble() < 0.1) {
            changeDirectionRandomly();
        }
        int xgoal = x+(Math.cos(angle* Math.pi/180)*speed).round();
        int ygoal = y+(Math.sin(angle*Math.pi/180)*speed).round();
        digDirt(xgoal,ygoal, dirtCanvas);

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

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas) {
        move(dirtCanvas);
        goRight ? citizenCanvas.context2D.drawImage(imageRight,x, y):citizenCanvas.context2D.drawImage(imageLeft,x, y);
    }
}