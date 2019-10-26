import 'dart:async';
import 'dart:html';
import 'package:LoaderLib/Loader.dart';

import 'Citizen.dart';

class World {


    //TODO probably seperate out the camera into its own thing
    int cameraUpperLeftX = -500;
    int cameraUpperLeftY = -500;
    static int cameraWidth = 1000;
    static int cameraHeight = 1000;
    static int worldWidth = 2000;
    static int worldHeight = 2000;
    int minHeight = -1000;
    int maxHeight = 0;
    int tickRate = 1000;
    int minWidth = -1000;
    int maxWidth = 0;
    CanvasElement screenCanvas = new CanvasElement(width:cameraWidth,height:cameraHeight);
    //not just what's on screen
    CanvasElement dirtCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    CanvasElement citizenCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    List<Citizen> citizens = new List<Citizen>();
    World() {
        citizens.add(new Citizen(1000,1000));
    }

    void attachToScreen(Element container) async {
        container.append(screenCanvas);
        ImageElement img = await Loader.getResource("images/dirtbox.png");
        dirtCanvas.context2D.drawImage(img,0,0);

        //TODO figure out what portion of the image to render.
        screenCanvas.style.backgroundImage = "url(images/skybox.png)";
        syncCamera();
        bool mouseDown = false;

        screenCanvas.onMouseMove.listen((MouseEvent e) {
            Rectangle rect = screenCanvas.getBoundingClientRect();
            Point point = new Point(e.client.x-rect.left, e.client.y-rect.top);
            moveCamera(point);
            if(mouseDown) {
                removeChunk(point);
            }
        });


        screenCanvas.onMouseDown.listen((MouseEvent e) {
            mouseDown = true;
        });

        screenCanvas.onMouseUp.listen((MouseEvent e) {
            mouseDown = false;
        });
    }

    void removeChunk(Point point) {
        double x = point.x -cameraUpperLeftX;
        double y = point.y -cameraUpperLeftY;
        print("removing chunk at position ${x} , ${y}");
        int size = 13;
        dirtCanvas.context2D.clearRect(x-size/2,y-size/2,size, size);
        syncCamera();
    }

    void moveCamera(Point p) {
        print("moving camera to $p");
        //left
        if(p.x < 100) {
            cameraUpperLeftX += 10;
        }else if(p.x > 900) { //right
            cameraUpperLeftX += -10;
        }

        if(p.y < 100) { //top
            cameraUpperLeftY += 10;
        }else if(p.y > 900) {
            cameraUpperLeftY += -10;
        }

        if(cameraUpperLeftY > maxHeight) cameraUpperLeftY = maxHeight;
        if(cameraUpperLeftY < minHeight) cameraUpperLeftY = minHeight;
        if(cameraUpperLeftX < minWidth) cameraUpperLeftX = minWidth;
        if(cameraUpperLeftX > maxWidth) cameraUpperLeftX = maxWidth;

        syncCamera();
    }

    void tick() {
        citizenCanvas.context2D.clearRect(0,0,worldWidth, worldHeight);
        citizens.forEach((Citizen c) => c.tick(citizenCanvas,dirtCanvas));
        syncCamera();
        new Timer(new Duration(milliseconds: tickRate), () => {
            tick()
        });
    }

    void syncCamera() {
        print("syncing camera to ${cameraUpperLeftX}px ${cameraUpperLeftY}px ");
        screenCanvas.style.backgroundPosition = "${cameraUpperLeftX}px ${cameraUpperLeftY}px";
        screenCanvas.context2D.clearRect(0,0,cameraWidth, cameraHeight);
        screenCanvas.context2D.drawImage(dirtCanvas, cameraUpperLeftX, cameraUpperLeftY);
        screenCanvas.context2D.drawImage(citizenCanvas, cameraUpperLeftX, cameraUpperLeftY);
    }

}