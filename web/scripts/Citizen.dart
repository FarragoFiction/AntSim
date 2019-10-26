import 'dart:html';
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
    bool goRight = true;

    Citizen(int this.x, int this.y) {
        imageLeft = new ImageElement(src: imageLocationLeft);
        imageRight = new ImageElement(src: imageLocationRight);

    }

    void changeDirectionRandomly() {
        angle = new Random().nextIntRange(0,360);
        if(angle > 90 && angle < 270) {
            goRight = true;
        }else {
            goRight = false;
        }
    }

    //todo care about and take in dirtcanvas
    void move(CanvasElement dirtCanvas) {
        if(new Random().nextDouble() < 0.1) {
            changeDirectionRandomly();
        }
        x += (Math.cos(angle)*speed).round();
        y += (Math.sin(angle)*speed).round();
        int size = 20;
        dirtCanvas.context2D.clearRect(x,y,size, size);
    }

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas) {
        move(dirtCanvas);
        goRight ? citizenCanvas.context2D.drawImage(imageRight,x, y):citizenCanvas.context2D.drawImage(imageLeft,x, y);
    }
}