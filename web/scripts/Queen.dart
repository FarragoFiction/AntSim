import 'dart:html';
import 'dart:typed_data';
import 'dart:math' as Math;
import 'World.dart';

class Queen {
    String imageLocation = "images/queen.png";
    ImageElement image;
    CanvasElement canvas;
    //in world coordinates, not screen coordinates
    int x = 1000;
    int y = 1500;
    //no life span , utterly immortal
    //BUT, if no food, will not produce offspring
    int size = 18;

    Queen() {
        image=new ImageElement(src: imageLocation);
    }

    CanvasElement initializeCanvas(ImageElement image) {
        int width = image.width;
        if(width == null || width == 0) width = 18;
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
        print("drawing pheremones");
        int radius;
        for(int i = 0; i < 10; i++) {
            radius = i * 100;
            queenPheremoneCanvas.context2D.setFillColorRgb(46, 0, 23, 0.1);
            queenPheremoneCanvas.context2D.beginPath();
            queenPheremoneCanvas.context2D.arc(
                x, y, radius, 0, Math.pi * 2, true);
            queenPheremoneCanvas.context2D.fill();
        }
    }

    void tick(CanvasElement citizenCanvas, CanvasElement dirtCanvas) {
        print("queen tick");
        initializeSprites();
        //queens can't move but they CAN fall.
        if(falling(dirtCanvas)) {
            print("queen is falling");
            y += 10;
        }
        //TODO spawn more echidnas
        citizenCanvas.context2D.drawImage(canvas,x, y);
    }

    void initializeSprites() {
        if(canvas == null) {
            canvas = initializeCanvas(image);
        }
    }

}