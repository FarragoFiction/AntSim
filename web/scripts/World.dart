import 'dart:async';
import 'dart:html';
import 'package:CommonLib/Random.dart';
import 'package:LoaderLib/Loader.dart';

import 'Citizen.dart';
import 'Food.dart';
import 'Queen.dart';

class World {

    ImageElement dirt;
    //TODO probably seperate out the camera into its own thing
    int cameraUpperLeftX = -500;
    int cameraUpperLeftY = -500;
    int maxSubjects = 113;
    static int cameraWidth = 1000;
    static int cameraHeight = 1000;
    int maxCitizens = 113;
    static int worldWidth = 2000;
    static int worldHeight = 2000;
    static int minHeight = -1000;
    static int maxHeight = 0;
    int tickRate = 100;
    static int minWidth = -1000;
    static int maxWidth = 0;
    //i only expect one but one never can be too careful
    List<Queen> queens = new List<Queen>();
    List<Food> food = new List<Food>();
    CanvasElement screenCanvas = new CanvasElement(width:cameraWidth,height:cameraHeight);
    //not just what's on screen
    CanvasElement dirtCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    CanvasElement queenPheremoneCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    CanvasElement foodPheremoneCanvas = new CanvasElement(width:worldWidth,height:worldHeight);

    CanvasElement citizenCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    List<Citizen> citizens = new List<Citizen>();
    World() {
        Random rand = new Random();
        for(int i = 0; i<3; i++) {
            int x = rand.nextInt(1500)+30;
            int y = rand.nextInt(1500)+30;
            citizens.add(new Citizen(1000, 900)..canDig=true);
        }
        queens.add(new Queen());
        for(int i =0; i< 3; i++) {
            int x = rand.nextInt(1500)+30;
            int y = rand.nextInt(1500)+30;
            spawnFoodAtPoint(x,y);
        }
    }

    void spawnFoodAtPoint(int x, int y) {
        food.add(new Food(x,y));
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

    void drawFoodPheremones() {
        foodPheremoneCanvas.context2D.clearRect(0,0,foodPheremoneCanvas.width, foodPheremoneCanvas.height);
        for(Food f in food) {
            f.drawPheremones(foodPheremoneCanvas);
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

    bool canSpawn() {
        return citizens.length < maxCitizens;
    }

    void tick() {
        citizenTick();
        queenTick();
        foodTick();
        syncCamera();
        new Timer(new Duration(milliseconds: tickRate), () => {
        tick()
        });
    }

    void citizenTick() {
        citizenCanvas.context2D.clearRect(0,0,worldWidth, worldHeight);
        citizens.forEach((Citizen c) => c.tick(this));
    }

    void queenTick() {
        drawQueenPheremones();
        queens.forEach((Queen c) => c.tick(citizenCanvas,dirtCanvas,this));
    }

    void foodTick() {
        drawFoodPheremones();
        food.forEach((Food f) => f.tick(citizenCanvas,dirtCanvas,this));
    }

    //find food nearest to x,y, to carry to the queen
    void giveCitizenFood(Citizen c) {
        //first find food
        //then give it to the citizen (who will carry it)
        Food chosen;
        for(Food f in food) {
            if((f.x - c.x).abs() < 10) {
                chosen = f;
                break;
            }
        }
        if(chosen != null) {
            c.carry(chosen);
        }
    }

    //give queen nearest to this x,y food
    void giveQueenFood(Citizen c) {
        Queen chosen;
        for(Queen q in queens) {
            if((q.x - c.x).abs() < 10) {
                chosen = q;
                break;
            }
        }
        if(chosen != null) {
            chosen.beFed(c,this);
        }
    }

    void syncCamera() {
        screenCanvas.style.backgroundPosition = "${cameraUpperLeftX}px ${cameraUpperLeftY}px";
        screenCanvas.context2D.clearRect(0,0,cameraWidth, cameraHeight);
        screenCanvas.context2D.drawImage(dirtCanvas, cameraUpperLeftX, cameraUpperLeftY);
        screenCanvas.context2D.drawImage(citizenCanvas, cameraUpperLeftX, cameraUpperLeftY);
        //only turn on phermone layers for debug purposes
        //screenCanvas.context2D.drawImage(queenPheremoneCanvas, cameraUpperLeftX, cameraUpperLeftY);
       // screenCanvas.context2D.drawImage(foodPheremoneCanvas, cameraUpperLeftX, cameraUpperLeftY);


    }

}