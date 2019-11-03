import 'dart:html';
import 'dart:typed_data';
import 'dart:math' as Math;
import 'package:CommonLib/Random.dart';

import 'Citizen.dart';
import 'World.dart';

class Food {
    String imageLocation = "images/meat.png";
    ImageElement image;
    CanvasElement canvas;
    //in world coordinates, not screen coordinates
    int x = 1000;
    int y = 1000;
    int size = 13;
    int trueSize = 100;

    int food = 113;

    Food(int this.x, int this.y) {
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


    void drawPheremones(CanvasElement pheremoneCanvas) {
        int radius = 500;
        int bands = 10;
        var grd = pheremoneCanvas.context2D.createRadialGradient(x,y,radius/bands, x,y,radius);
        grd.addColorStop(0, "rgb(255, 0, 0, 1.0)");
        grd.addColorStop(1, "rgb(255, 0, 0,0.0)");
        pheremoneCanvas.context2D.beginPath();
        pheremoneCanvas.context2D.arc(
            x, y, radius, 0, Math.pi * 2, true);
        pheremoneCanvas.context2D.fillStyle = grd;
        pheremoneCanvas.context2D.fill();
    }

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas, World world) {
        initializeSprites();
        if(falling(dirtCanvas)) {
            y += 10;
        }
        citizenCanvas.context2D.drawImage(canvas,x, y);
    }

    void initializeSprites() {
        if(canvas == null) {
            canvas = initializeCanvas(image);
        }
    }

}