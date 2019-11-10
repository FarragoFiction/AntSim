import 'dart:html';
import 'dart:typed_data';
import 'package:CommonLib/Random.dart';
import 'dart:math' as Math;

import 'Food.dart';
import 'World.dart';
class Enemy {
    String imageLocationLeft = "images/friend.png";
    String imageLocationRight = "images/friendRight.png";

    ImageElement imageLeft;
    ImageElement imageRight;
    CanvasElement canvasLeft;
    CanvasElement canvasRight;
    //in world coordinates, not screen coordinates
    int x;
    int y;
    int angle = 0;
    int runSpeed = 10;
    int size = 100;
    int age = 0;
    int maxAge = 777;
    bool goRight = true;

    Enemy(int this.x, int this.y) {
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

    //gravity is banned. it messes up pheremones.
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
        int x2 = iToX(index, width) - (width/2).round();
        int y2 = iToY(index,width) - (width/2).round();
       // print("x2 is $x2");
       // print("y2 is $y2");
        //print("so atan2 would be ${Math.atan2(y2, x2)} and converted to degrees thats ${((180/Math.pi)*Math.atan2(y2, x2)).round()} ");
        return ((180/Math.pi)*Math.atan2(y2, x2)).round();
    }
    //if i'm at i = 13 of a 10 wide image
    //then my x coordinate is 3, and my y coordinate is 1
    // or i%10 and i/10 respectively
    int iToX(int i, int width) {
        return i % width;
    }

    int iToY(int i, int width) {
        return (i / width).floor();
    }

    void die(World w) {
        Food myCorpse = new Food(x,y)..foodValue = 113; //enough to make a new bee, if you can collect it
        w.food.add(myCorpse);
        w.enemiesToRemove.add(this);
    }

    void drawPheremones(CanvasElement canvas) {
        int radius = 500;
        int bands = 255;
        int xCenter = (x+size/2).round();
        int yCenter = (y+size/2).round();
        var grd = canvas.context2D.createRadialGradient(xCenter,yCenter,radius/bands, xCenter,yCenter,radius);
        grd.addColorStop(0, "rgb(0, 0, 255, 1.0)");
        grd.addColorStop(1, "rgb(0, 0, 255,0)");
        canvas.context2D.beginPath();
        canvas.context2D.arc(
            xCenter, yCenter, radius, 0, Math.pi * 2, true);
        canvas.context2D.fillStyle = grd;
        canvas.context2D.fill();
    }



    void move(World world , [bool secondTry = false]) {
        int xgoal = x+(Math.cos(angle* Math.pi/180)*runSpeed).round();
        int ygoal = y+(Math.sin(angle*Math.pi/180)*runSpeed).round();
        if(new Random().nextDouble() <0.1) {
            changeDirectionRandomly();
        }
        if(canMove(xgoal,ygoal,world.dirtCanvas)){
            x = xgoal;
            y = ygoal;
        }else {
            //try to move again, but ignore ai
            if(!secondTry) move(world,true);
            return;
        }
    }

    CanvasElement initializeCanvas(ImageElement image) {
        int width = image.width;
        if(width == null || width == 0) width = size;
        CanvasElement canvas = new CanvasElement(width: width, height: width);
        if(image.width != 0) {
            canvas.context2D.drawImage(image,0,0);
        }
        image.onLoad.listen((Event e) {
            canvas.context2D.drawImage(image,0,0);
        });
        return canvas;
    }

    void tick(World world) {

        age += -1;
        if(age > maxAge) die(world);
        move(world);
        if(canvasLeft == null || canvasRight == null) initializeSprites();
        goRight ? world.citizenCanvas.context2D.drawImage(canvasRight,x, y):world.citizenCanvas.context2D.drawImage(canvasLeft,x, y);
    }

    void initializeSprites() {
          canvasLeft = initializeCanvas(imageLeft);
          canvasRight = initializeCanvas(imageRight);
    }
}