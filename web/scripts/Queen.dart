import 'dart:html';
import 'dart:typed_data';
import 'dart:math' as Math;
import 'package:CommonLib/Random.dart';

import 'Citizen.dart';
import 'World.dart';

class Queen {
    String imageLocation = "images/queen.png";
    ImageElement image;
    CanvasElement canvas;
    //in world coordinates, not screen coordinates
    int x = 1000;
    int y = 1000;
    //no life span , utterly immortal
    //BUT, if no food, will not produce offspring
    int size = 18;
    int trueSize = 100;

    int food = 113;

    Queen() {
        x = new Random().nextInt(1500)+100;
        y = new Random().nextInt(200) + 1000;
        image=new ImageElement(src: imageLocation);
    }

    CanvasElement initializeCanvas(ImageElement image) {
        int width = image.width;
        if(width == null || width == 0) width = trueSize;
        CanvasElement canvas = new CanvasElement(width: width, height: width);
        image.onLoad.listen((Event e) {
            canvas.context2D.drawImage(image,0,0);
        });
        return canvas;
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


    void drawPheremones(CanvasElement queenPheremoneCanvas) {
        int radius = 2000;
        int bands = 255;
        var grd = queenPheremoneCanvas.context2D.createRadialGradient(x,y,radius/bands, x,y,radius);
        grd.addColorStop(0, "rgb(255, 0, 255, 1.0)");
        grd.addColorStop(1, "rgb(255, 0, 255,0)");
        queenPheremoneCanvas.context2D.beginPath();
        queenPheremoneCanvas.context2D.arc(
            x, y, radius, 0, Math.pi * 2, true);
        queenPheremoneCanvas.context2D.fillStyle = grd;
        queenPheremoneCanvas.context2D.fill();
    }

    void beFed(Citizen c, World w) {
        if(c.food != null) {
            w.food.remove(c.food);
            c.drop();
            food += 113;
        }
    }

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas, World world) {
        food += -1;
        initializeSprites();
        //keep queen fed and she'll make more citizens
        if(world.canSpawn() && food > 0) {
            if(new Random().nextDouble() > 0.9) {
                food += -1;
                world.citizens.add(new Citizen(x, y));
                if(new Random().nextDouble() > 0.9) {
                    food += -13;
                    world.citizens.add(new Citizen(x, y)..canDig = true);
                }
            }
        }
        citizenCanvas.context2D.drawImage(canvas,x, y);
    }

    void initializeSprites() {
        if(canvas == null) {
            canvas = initializeCanvas(image);
        }
    }

}