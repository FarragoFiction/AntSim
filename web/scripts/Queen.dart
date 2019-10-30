import 'dart:html';
import 'dart:typed_data';

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