import 'dart:async';
import 'dart:html';
import 'package:CommonLib/Random.dart';
import 'package:LoaderLib/Loader.dart';
import 'package:dynamicMusic/dynamicMusic.dart';
import 'Citizen.dart';
import 'Controls.dart';
import 'Enemy.dart';
import 'Food.dart';
import 'Queen.dart';

class World {
    static const String DIGMODE = "DIGMODE";
    int musicIndex = 0;
    static const String DIRTMODE = "DIRTMODE";
    bool initializingMusic = false;
    static const String FOODMODE = "FOODMODE";
    bool viewEnemyPheremones = false;
    bool viewQueenPheremones = false;
    bool viewFoodPheremones = false;
    DynamicSong song;

    String mode = DIGMODE;
    ImageElement dirt;
    //TODO probably seperate out the camera into its own thing
    int cameraUpperLeftX = -500;
    int cameraUpperLeftY = -500;
    int maxSubjects = 113;
    static int cameraWidth = 1000;
    static int cameraHeight = 600;
    int maxCitizens = 113;
    static int worldWidth = 2000;
    static int worldHeight = 2000;
    static int minHeight = -1000;
    static int maxHeight = 0;
    int tickRate = 100;
    int enemyRate = 20000;
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
    CanvasElement enemyPheremoneCanvas = new CanvasElement(width:worldWidth,height:worldHeight);

    CanvasElement citizenCanvas = new CanvasElement(width:worldWidth,height:worldHeight);
    List<Citizen> citizens = new List<Citizen>();
    List<Enemy> enemies = new List<Enemy>();

    List<Citizen> citizensToRemove = new List<Citizen>();
    List<Enemy> enemiesToRemove = new List<Enemy>();
    List<Food> foodToRemove = new List<Food>();

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
        print("trying to spawn food at point $x, $y, total food is ${food.length}");
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

    void drawEnemyPheremones() {
        enemyPheremoneCanvas.context2D.clearRect(0,0,enemyPheremoneCanvas.width, enemyPheremoneCanvas.height);
        for(Enemy enemy in enemies) {
            enemy.drawPheremones(enemyPheremoneCanvas);
        }
    }

    void drawFoodPheremones() {
        foodPheremoneCanvas.context2D.clearRect(0,0,foodPheremoneCanvas.width, foodPheremoneCanvas.height);
        for(Food f in food) {
            f.drawPheremones(foodPheremoneCanvas);
        }
    }

    void setMusic() {
        if(song == null && !initializingMusic) {
            print("initializing music");
            initializingMusic = true;
            musicIndex = antCountToIndex();
            List<String> urls = [
                "music/ant1.mp3",
                "music/ant2.mp3",
                "music/ant3.mp3",
                "music/ant4.mp3",
                "music/ant5.mp3",
                "music/ant6.mp3",
                "music/ant7.mp3",
                "music/ant8.mp3"
            ];
            song = new DynamicSong(urls);
            song.startWhenReady();
        }else if(song != null){
            int hopefulIndex = antCountToIndex();
            if (musicIndex != hopefulIndex) {
                print(
                    "hopeful index is differnet, changing from ${musicIndex} to ${hopefulIndex} at time ${DateTime
                        .now()}");
                musicIndex = hopefulIndex;
                song.swapSong(musicIndex);
            }
        }
    }

    //8 total
    int antCountToIndex() {
        if(citizens.length < 3) {
            return 0;
        }else if(citizens.length < 13) {
            return 1;
        }else if(citizens.length < 25) {
            return 2;
        }else if(citizens.length < 45) {
            return 3;
        }else if(citizens.length < 60) {
            return 4;
        }else if(citizens.length < 80) {
            return 5;
        }else if(citizens.length < 100) {
            return 6;
        }else{
            return 7;
        }
    }

    void start() {
        tick();
        spawnEnemyLoop();
    }

    void attachToScreen(Element container) async {
        DivElement game = new DivElement()..classes.add("game");
        container.append(game);
        ImageElement frame = new ImageElement(src: "images/frame.png")..classes.add("frame");
        game.append(frame);
        DivElement instructions = new DivElement()..text = "CLICK TO START"..classes.add("start");
        Controls.generate(game, this);
        game.append(instructions);
        StreamSubscription listener;
        listener = window.onClick.listen((Event e) {
            listener.cancel();
            start();
            instructions.remove();
        });

        screenCanvas.classes.add("gameviewport");
        game.append(screenCanvas);
        await initImage();
        drawQueenPheremones();
        drawEnemyPheremones();
        dirtCanvas.context2D.drawImageScaled(dirt,0,0,2000,2000);
        screenCanvas.style.backgroundImage = "url(images/skybox.png)";
        syncCamera();
        bool mouseDown = false;

        screenCanvas.onMouseMove.listen((MouseEvent e) {
            Rectangle rect = screenCanvas.getBoundingClientRect();
            Point point = new Point(e.client.x-rect.left, e.client.y-rect.top);
           // moveCamera(point);
            if(mouseDown) {
                if(mode == DIGMODE) {
                    removeChunk(point);
                }else if(mode == DIRTMODE) {
                    spawnDirtChunk(point);
                }
            }
        });


        screenCanvas.onMouseDown.listen((MouseEvent e) {
            mouseDown = true;
            print("mode is $mode");
            Rectangle rect = screenCanvas.getBoundingClientRect();
            Point point = new Point(e.client.x-rect.left, e.client.y-rect.top);
            if(mode == FOODMODE) {

                spawnFoodChunk(point);
            }else if(mode == DIGMODE) {
                removeChunk(point);
            }else if(mode == DIRTMODE) {
                spawnDirtChunk(point);
            }

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

    void spawnDirtChunk(Point point) {
        double x = point.x -cameraUpperLeftX;
        double y = point.y -cameraUpperLeftY;
        int size = 22;
        Random rand = new Random();
        double saturation = rand.nextDoubleRange(50.0,100.0);
        double lumin = rand.nextDoubleRange(0.0,30.0);
        dirtCanvas.context2D.setFillColorHsl(26,saturation,lumin);
        dirtCanvas.context2D.fillRect(x-size/2,y-size/2,size, size);
        syncCamera();
    }

    void spawnFoodChunk(Point point) {
        double x = point.x -cameraUpperLeftX;
        double y = point.y -cameraUpperLeftY;
        spawnFoodAtPoint(x.round(),y.round());
    }

    void moveCameraLeft() {
        cameraUpperLeftX += 10;
        handleCameraMove();
    }

    void moveCameraRight() {
        cameraUpperLeftX += -10;
        handleCameraMove();
    }

    void moveCameraUp() {
        cameraUpperLeftY += 10;
        handleCameraMove();
    }

    void moveCameraDown() {
        cameraUpperLeftY += -10;
        handleCameraMove();
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

        handleCameraMove();
    }

    void handleCameraMove() {
      if(cameraUpperLeftY > maxHeight) cameraUpperLeftY = maxHeight;
      if(cameraUpperLeftY < minHeight) cameraUpperLeftY = minHeight;
      if(cameraUpperLeftX < minWidth) cameraUpperLeftX = minWidth;
      if(cameraUpperLeftX > maxWidth) cameraUpperLeftX = maxWidth;

      syncCamera();
    }

    bool canSpawn() {
        return citizens.length < maxCitizens;
    }

    void spawnEnemyLoop() {
        if(enemies.length < 3) {
            enemies.add(new Enemy(new Random().nextIntRange(200, 1600), 500));
        }
        new Timer(new Duration(milliseconds: enemyRate), () => {
        spawnEnemyLoop()
        });
    }

    void tick() {
        setMusic();
        citizenTick();
        queenTick();
        foodTick();
        syncCamera();
        new Timer(new Duration(milliseconds: tickRate), () => {
        tick()
        });
    }

    void citizenTick() {
        citizensToRemove.forEach((Citizen c) => citizens.remove(c));
        citizensToRemove.clear();
        enemiesToRemove.forEach((Enemy c) => enemies.remove(c));
        enemiesToRemove.clear();
        citizenCanvas.context2D.clearRect(0,0,worldWidth, worldHeight);
        enemies.forEach((Enemy e) => e.tick(this));
        drawEnemyPheremones();
        citizens.forEach((Citizen c) => c.tick(this));
    }

    void queenTick() {
        drawQueenPheremones();
        queens.forEach((Queen c) => c.tick(citizenCanvas,dirtCanvas,this));
    }

    void foodTick() {
        foodToRemove.forEach((Food f) => food.remove(f));
        foodToRemove.clear();
        drawFoodPheremones();
        food.forEach((Food f) => f.tick(citizenCanvas,dirtCanvas,this));
    }

    //find food nearest to x,y, to carry to the queen
    void giveCitizenFood(Citizen c) {
        //first find food
        //then give it to the citizen (who will carry it)
        Food chosen;
        for(Food f in food) {
            if((f.x - c.x).abs() < 10 && (f.y - c.y).abs() < 10) {
                chosen = f;
                break;
            }
        }
        if(chosen != null) {
            c.carry(chosen);
        }
    }

    void checkCombat(Enemy enemy) {
        bool killedOne = false;
        int hitCount = 0;
        Random rand = new Random();
        for(Citizen c in citizens) {
            int radius = 75;
            if((enemy.x - c.x).abs() < radius && (enemy.y - c.y).abs() < radius) {
                if(!killedOne && rand.nextDouble() < 0.3) {
                    c.die(this);
                }else {
                    hitCount ++;
                }
            }
        }
        if(hitCount != 0) enemy.applyHits(this,hitCount);
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
        if(viewQueenPheremones) {
            screenCanvas.context2D.drawImage(
                queenPheremoneCanvas, cameraUpperLeftX, cameraUpperLeftY);
        }
        if(viewFoodPheremones) {
            screenCanvas.context2D.drawImage(
                foodPheremoneCanvas, cameraUpperLeftX, cameraUpperLeftY);
        }

        if(viewEnemyPheremones) {
            screenCanvas.context2D.drawImage(
                enemyPheremoneCanvas, cameraUpperLeftX, cameraUpperLeftY);
        }


    }

}