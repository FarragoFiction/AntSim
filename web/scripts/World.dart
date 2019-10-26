import 'dart:html';

class World {
    CanvasElement canvas = new CanvasElement(width:1000,height:1000);
    //TODO probably seperate out the camera into its own thing
    int cameraUpperLeftX = -500;
    int cameraUpperLeftY = -500;
    int cameraWidth = 1000;
    int cameraHeight = 1000;
    int minHeight = -1000;
    int maxHeight = 0;

    World() {

    }

    void attachToScreen(Element container) {
        container.append(canvas);
        //TODO figure out what portion of the image to render.
        canvas.style.backgroundImage = "url(images/skybox.png)";
        syncCamera();
        canvas.onMouseMove.listen((MouseEvent e) {
            Rectangle rect = canvas.getBoundingClientRect();
            Point point = new Point(e.client.x-rect.left, e.client.y-rect.top);
            moveCamera(point);

        });
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

        syncCamera();
    }

    void syncCamera() {
        print("syncing camera to ${cameraUpperLeftX}px ${cameraUpperLeftY}px ");
        canvas.style.backgroundPosition = "${cameraUpperLeftX}px ${cameraUpperLeftY}px";
    }

}