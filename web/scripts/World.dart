import 'dart:async';
import 'dart:html';
import 'package:CommonLib/Random.dart';
import 'package:LoaderLib/Loader.dart';

import 'Citizen.dart';
import 'Queen.dart';

class World {

    ImageElement dirt;
    //TODO probably seperate out the camera into its own thing
    int cameraUpperLeftX = -500;
    int cameraUpperLeftY = -500;
    static int cameraWidth = 1000;
    static int cameraHeight = 1000;
    static int worldWidth = 2000;
    static int worldHeight = 2000;
    static int minHeight = -1000;
    static int maxHeight = 0;
    int tickRate = 100;
    static int minWidth = -1000;
    static int maxWidth = 0;
    //i only expect one but one never can be too careful
    List<Queen> queens = new List<Queen>();
    CanvasElement screenCanvas = new CanvasElement(width:cameraWidth,height:cameraHeight);
    //not just what's on screen
    CanvasElement dirtCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    CanvasElement queenPheremoneCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    CanvasElement citizenCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    List<Citizen> citizens = new List<Citizen>();
    World() {
        Random rand = new Random();
        for(int i = 0; i<10; i++) {
            int x = rand.nextInt(1500)+30;
            int y = rand.nextInt(1500)+30;
            for(int j = 0; j<10; j++) {
                citizens.add(new Citizen(x, y));
            }
            citizens.add(new Citizen(1000, 1000)..canDig=true);
        }
        queens.add(new Queen());
    }

    void teardown() {
        screenCanvas.remove();
    }

    void initImage() async {
        if(dirt == null) dirt = await Loader.getResource("images/dirtbox.png");
    }

    void drawQueenPheremones() {
        queenPheremoneCanvas.context2D.clearRect(0,0,queenPheremoneCanvas.width, queenPheremoneCanvas.height);
        for(Queen queen in queens) {
            queen.drawPheremones(queenPheremoneCanvas);
        }
    }

    void attachToScreen(Element container) async {
        container.append(screenCanvas);
        await initImage();
        drawQueenPheremones();
        dirtCanvas.context2D.drawImageScaled(dirt,0,0,2000,2000);
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
        int size = 33;
        dirtCanvas.context2D.clearRect(x-size/2,y-size/2,size, size);
        syncCamera();
    }

    void moveCamera(Point p) {
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
        drawQueenPheremones();
        citizens.forEach((Citizen c) => c.tick(citizenCanvas,dirtCanvas, queenPheremoneCanvas));
        queens.forEach((Queen c) => c.tick(citizenCanvas,dirtCanvas));

        syncCamera();
        new Timer(new Duration(milliseconds: tickRate), () => {
            //tick()
        });
    }

    void syncCamera() {
        screenCanvas.style.backgroundPosition = "${cameraUpperLeftX}px ${cameraUpperLeftY}px";
        screenCanvas.context2D.clearRect(0,0,cameraWidth, cameraHeight);
        screenCanvas.context2D.drawImage(dirtCanvas, cameraUpperLeftX, cameraUpperLeftY);
        screenCanvas.context2D.drawImage(citizenCanvas, cameraUpperLeftX, cameraUpperLeftY);
        screenCanvas.context2D.drawImage(queenPheremoneCanvas, cameraUpperLeftX, cameraUpperLeftY);

    }

}