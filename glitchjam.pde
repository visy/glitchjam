/* @pjs globalKeyEvents=true; 
pauseOnBlur=true; 
preload="tilemapsmall.png"; 
 */

float dt;
float st;
float et;

PImage tilemap;
PImage[] tiles;

ArrayList<Undoable> undoables;

int currentScreen = 0;
int screenCount = 40;

int currentLayer = 0;
int layerCount = 2;
String[] layerNames = { "BG","FG" };

int[][] screenBG; // layer 0
int[][] screenFG; // layer 1

int tilemapWidth;
int tilemapHeight;

int screenWidth = 40;
int screenHeight = 28;

int savedScreenCount;

int gridX = 0;
int gridY = 0;

int gridW = 4;
int gridH = 4;

int pScreenX = 0;
int pScreenY = 0;
int screenX = 0;
int screenY = 0;

Frame gridFrame;

int EDITORMODE_EDIT = 1;
int EDITORMODE_TEST = 2;
int EDITORMODE_PLAY = 3;

int worldX;
int worldY;

float playerHSpeed = 1.0;
float playerVSpeed = 0;
float playerJumpTimer = 0;
int playerOY;

boolean holdingLeft = false;
boolean holdingRight = false;
boolean holdingJump = false;

int showTilemap = 0;
int editormode = EDITORMODE_TEST;

boolean addedBlock = false;

void setupEditor() {
  showTilemap = 1;
  gridX = 0;
  gridY = 9;

  gridW = 2;
  gridH = 3;

  gridFrame = new Frame();
  gridFrame.x = gridX;
  gridFrame.y = gridY;
  gridFrame.w = gridW;
  gridFrame.h = gridH;
  
  undoables = new ArrayList<Undoable>();
}

void resetPlayerToStart() {
  worldX = 0; 
  worldY = 0; 
}

void resetScreens() {
  screenBG = new int[screenCount][screenWidth*screenHeight];
  screenFG = new int[screenCount][screenWidth*screenHeight];

  for (int j = 0; j < screenCount; j++) {
    screenBG[j] = new int[screenWidth*screenHeight];
    for (int i = 0; i < screenWidth*screenHeight; i++) screenBG[j][i] = 510;
    screenFG[j] = new int[screenWidth*screenHeight];
    for (int i = 0; i < screenWidth*screenHeight; i++) screenFG[j][i] = 510;

  }
  
  loadScreens();
  currentScreen = 0;
}

Sprite playerSprite;

void resetPlayer() {
  playerSprite = null;
  playerSprite = new Sprite(16, 22, 2, 3, 35, 5, 8);
  playerSprite.setAnimationLeft(0,1);
  playerSprite.setAnimationRight(4,5);
}

void setupGame() {
  resetPlayerToStart();
  resetScreens();
  resetPlayer();
}

void setup() {
  size(320,240);
  tilemap = loadImage("tilemapsmall.png");
  
  tilemapWidth = (int)(tilemap.width/8);
  tilemapHeight = (int)(tilemap.height/8);
  
  tiles = new PImage[tilemapWidth*tilemapHeight];
  
  for (int y = 0; y < tilemapHeight; y++) {
    for (int x = 0; x < tilemapWidth; x++) {
      tiles[(y*tilemapWidth)+x] = tilemap.get(x*8,y*8, 8,8);
    }
  }
  
  frameRate(30);
  imageMode(CORNERS);
  
  setupEditor();
  setupGame();
}

void drawTileset() {
  fill(0);
  noStroke();
  rect(0,8,tilemapWidth*8,tilemapHeight*8);
  image(tilemap,0,8);
}

void drawGrid(int x,int y,int w,int h) {
  pushMatrix();
  fill(0,64);
  stroke(0,255,0,255);
  rect(x*8,y*8,w*8,h*8);
  popMatrix();
}

void drawTileNum(int x, int y, int tnum) {
  image(tiles[tnum], x*8,y*8);
}

void drawTileXY(int x, int y, int tx, int ty) {
  image(tiles[(ty*tilemapWidth)+tx], x*8,y*8);
}

void drawFrame(int x, int y, Frame frame) {
  for (int fy = 0; fy<frame.h; fy++) {
    for (int fx = 0; fx<frame.w; fx++) {
      drawTileXY(x+fx,y+fy, frame.x+fx, frame.y+fy);
    }
  }
}

void renderEditorGUI() {
  fill(255,255);
  if (editormode == EDITORMODE_EDIT && showTilemap == 1) text("["+currentScreen + "/" + screenCount + "] " + "editor - tile picker (tilenum: " + (((screenY-1)*tilemapWidth)+screenX) + ", x/y: " + screenX + "/" + (screenY-1) + ", layer: " + layerNames[currentLayer] + ")",0,8);

  if (editormode == EDITORMODE_EDIT && showTilemap == -1) text("["+currentScreen + "/" + screenCount + "] " + "editor - world (" + "layer: " + layerNames[currentLayer] + ")",0,8);
  if (editormode == EDITORMODE_TEST) text("play test",0,8);
  if (editormode == EDITORMODE_PLAY) text("play - insert GUI here",0,8);

  if (editormode == EDITORMODE_EDIT && showTilemap == -1) {
    drawFrame((int)(width/8)-gridW, 0, gridFrame);
  }
}

boolean bgCached = false;
boolean fgCached = false;

void drawBG() {
  for (int y = 0; y < screenHeight; y++) {
    for (int x = 0; x < screenWidth; x++) {
      drawTileNum(x,y+1,screenBG[currentScreen][(y*screenWidth)+x]);
    }
  }
}

void drawFG() {
  for (int y = 0; y < screenHeight; y++) {
    for (int x = 0; x < screenWidth; x++) {
      drawTileNum(x,y+1,screenFG[currentScreen][(y*screenWidth)+x]);
    }
  }  
}

void playerCheckBounds() {
  if (playerSprite.wx < -1) playerSprite.wx = -1;
  if (playerSprite.wx > screenWidth-1) playerSprite.wx = screenWidth-1;
}

void playerLeft() {
  playerSprite.wx-=playerHSpeed;
  playerSprite.setDir(0);
  playerCheckBounds();
}

void playerRight() {
  playerSprite.wx+=playerHSpeed;
  playerSprite.setDir(1);
  playerCheckBounds();
}

boolean playerJumping = false;

void playerJump() {
  if (playerJumping) return;
       
  playerOY = playerSprite.wy;
  playerSprite.wy-=1;
  playerVSpeed = 0;
  playerJumpTimer = 0;
  jumpStarting = true;
  playerJumping = true;

}

int playerWalkSpeed = 15;

void drawPlayer() {
  if (holdingLeft || holdingRight) playerSprite.animate(playerWalkSpeed,dt);
  Frame pf;
  if (!playerJumping) pf = playerSprite.getAnimFrame();
  else { pf = playerSprite.getFrame(2+playerSprite.dir*4); }
  drawFrame(playerSprite.wx, playerSprite.wy, pf);
}

void renderGame() {
  //playerX+=playerXS;
  drawBG();
  drawPlayer();  
  drawFG();
}

void keyPressed() {
  if (key == ' ') showTilemap = -showTilemap;
  if (key == 't') { editormode = EDITORMODE_TEST; playerX = worldX; playerY = 0; }
  if (key == 'p') { editormode = EDITORMODE_PLAY; resetPlayerToStart(); }
  if (key == 'e') { editormode = EDITORMODE_EDIT; resetPlayer(); showTilemap = -1; }

  if (key == 'z') { currentLayer--; if (currentLayer < 0) currentLayer = 0; }
  if (key == 'x') { currentLayer++; if (currentLayer >= layerCount-1) currentLayer = layerCount-1; }

  if (key == 'n') { currentScreen--; if (currentScreen < 0) currentScreen = 0; }
  if (key == 'm') { currentScreen++; if (currentScreen >= screenCount-1) currentScreen = screenCount-1; }

  if (key == 'u') { undo(); }
  if (key == 'l') { loadScreen(); }
  if (key == 's') { saveScreen(); }

/*
  if (key == 'w') { if (scrollY > 0) scrollY--; }
  if (key == 's') { if (scrollY < mapHeight-1) scrollY++; }
  if (key == 'a') { if (scrollX > 0) scrollX--; }
  if (key == 'd') { if (scrollX < mapWidth-1) scrollX++;}
*/

  if (editormode == EDITORMODE_EDIT) {
    if (key == CODED) {
      if (keyCode == UP) {
        gridY-=gridH;
        if (gridY < 1) gridY = 1;
      }
      else if (keyCode == DOWN) {
        gridY+=gridH;
        if (gridY+gridH > (int)(tilemap.height/8)-6) gridY = (int)(tilemap.height/8)-7;
      }
      else if (keyCode == LEFT) {
        gridX-=gridW;
        if (gridX < 0) gridX = 0;
      }
      else if (keyCode == RIGHT) {
        gridX+=gridW;
        if (gridX+gridW > (int)(tilemap.width/8)) gridX = (int)(tilemap.width/8);
      }
    }
  }
  
}

void keyReleased() {
 
  if (key == CODED) {
    if (keyCode == UP) holdingJump = false;
    if (keyCode == LEFT) holdingLeft = false;
    if (keyCode == RIGHT) holdingRight = false;
  }
}

String[] screenToStrings() {
  String screenData = "";
  
  for (int i = 0; i < (screenWidth*screenHeight); i++) {
    screenData += screenBG[currentScreen][i] + ",";
  }
  for (int i = 0; i < (screenWidth*screenHeight); i++) {
    if (i < (screenWidth*screenHeight)-1) screenData += screenFG[currentScreen][i] + ",";
    else screenData += screenFG[currentScreen][i];
  }
  
  return screenData.split(',');
}

void loadScreens() {
	for(int i = 0; i < screenCount; i++) {
		currentScreen = i;
		loadScreen(false);
	}
}

void loadScreen() {
	loadScreen(true);
}

void loadScreen(boolean verbose) {
  if (verbose) println("loading " + "scrdata"+currentScreen+".dat" + "...");
	int iter = 0;
	int iter2 = 0;
	if (localStorage["scrdata"+currentScreen+".dat"] == null) return;
	String lines[] = loadStrings("scrdata"+currentScreen+".dat");
	if (lines == null) return;
	if (lines.length < screenWidth*screenHeight) return;
	for (int i=0; i < lines.length; i++) {
	  if (iter < screenWidth*screenHeight) screenBG[currentScreen][iter++] = parseInt(lines[i]);
	  else screenFG[currentScreen][iter2++] = parseInt(lines[i]);
	}
  if (verbose) println("loading complete.");
}

void saveScreen() {
  println("saving...");
  saveStrings("scrdata"+currentScreen+".dat", screenToStrings());
  println("saving complete. filename: " + "scrdata"+currentScreen+".dat");
}

void undo() {
  if (undoables.size() <= 0) return; 

  Undoable u = undoables.get(undoables.size()-1);
  int tileCounter = 0;

  for (int y = 0; y < u.frame.h; y++) {
    for (int x = 0; x < u.frame.w; x++) {
      if ((u.sx+x) < screenWidth) {
        int tilenum = u.savedBlock[tileCounter];
        tileCounter++;
        
        if (u.layer == 0) 
          screenBG[currentScreen][((u.sy+y-1)*screenWidth)+(u.sx+x)] = tilenum;
        else if (u.layer == 1) 
          screenFG[currentScreen][((u.sy+y-1)*screenWidth)+(u.sx+x)] = tilenum;
      }
    }
  }
  
  undoables.remove(undoables.size()-1);
  
}

void addCurrentBlock() {

  int[] savedBlock = new int[gridFrame.h*gridFrame.w];
  int tileCounter = 0;

  for (int y = 0; y < gridFrame.h; y++) {
    for (int x = 0; x < gridFrame.w; x++) {
      if ((screenX+x) < screenWidth) {
        int tilenum = ((y+gridFrame.y)*tilemapWidth)+(x+gridFrame.x);

        if (currentLayer == 0) {
          savedBlock[tileCounter] = screenBG[currentScreen][((screenY+y-1)*screenWidth)+(screenX+x)];
          screenBG[currentScreen][((screenY+y-1)*screenWidth)+(screenX+x)] = tilenum;
        }
        else if (currentLayer == 1) {
          savedBlock[tileCounter] = screenFG[currentScreen][((screenY+y-1)*screenWidth)+(screenX+x)];
          screenFG[currentScreen][((screenY+y-1)*screenWidth)+(screenX+x)] = tilenum;
        }

        tileCounter++;

      }
    }
  }
  
  Undoable u = new Undoable(gridFrame, currentLayer,screenX,screenY,savedBlock,tileCounter);
  undoables.add(u);
}

void inputHandler() {
  if (editormode == EDITORMODE_EDIT && showTilemap == 1) {
    if (mousePressed == true) {
      gridX = (int)(mouseX/8);
      gridY = (int)(mouseY/8);
      if (gridY <= 0) gridY = 1;
    }
     
    if (key == '1') { gridW = 1; gridH = 1; }
    else if (key == '2') { gridW = 2; gridH = 1; }
    else if (key == '3') { gridW = 2; gridH = 2; }
    else if (key == '3') { gridW = 2; gridH = 2; }
    else if (key == '4') { gridW = 2; gridH = 3; }
    else if (key == '5') { gridW = 4; gridH = 4; }
    else if (key == '6') { gridW = 6; gridH = 6; }

  }
  
  gridFrame.x = gridX;
  gridFrame.y = gridY-1;
  gridFrame.w = gridW;
  gridFrame.h = gridH;
 
  pScreenX = screenX;
  pScreenY = screenY;
  screenX = (int)(mouseX/8);
  screenY = (int)(mouseY/8);
  if (screenY <= 0) screenY = 1;
  if (screenY >= screenHeight) screenY = screenHeight;

  if (editormode == EDITORMODE_EDIT && showTilemap != 1) {

    if (pScreenX != screenX) addedBlock=false;
    if (pScreenY != screenY) addedBlock=false;

    if (mousePressed == true && addedBlock == false) {
      addCurrentBlock();
      addedBlock = true;
    }
    
    if (mousePressed == false) {
      addedBlock = false;
    }
  }
  
  // game
  
  if (editormode == EDITORMODE_TEST || editormode == EDITORMODE_PLAY) {
    if (key == CODED && keyPressed == true) {
      if (keyCode == UP) {
        holdingJump = true;
        keyCode = null;
      }
      if (keyCode == DOWN) {
        //playerAction();
      }
      if (keyCode == LEFT) {
        holdingLeft = true;
        holdingRight = false;
      }
      else if (keyCode == RIGHT) {
        holdingRight = true;
        holdingLeft = false;
      }
    }
  }

}

void renderEditor() {
  if (editormode == EDITORMODE_EDIT) {
    if (showTilemap == 1) {
      drawTileset();
      drawGrid(gridX, gridY, gridW, gridH);
    }
    else {
      drawFrame(screenX, screenY, gridFrame);
      drawGrid(screenX, screenY, gridW, gridH);
    }
  }

  renderEditorGUI();
}

boolean jumpStarting = false;

void physics() {
  if (editormode == EDITORMODE_EDIT) return;
  playerHSpeed = dt*0.04;
  
    if (holdingLeft) playerLeft();
    else if (holdingRight) playerRight();
  
  if (holdingLeft) text("left",64,64);
  if (holdingRight) text("right",64,92);
  
  if (holdingJump) playerJump();


  if (playerJumping) {    
    if (jumpStarting) {
      playerVSpeed=cos((playerJumpTimer)*0.02)*0.3;
    }

    if (playerJumpTimer < 170) playerJumpTimer+=dt;
    else playerVSpeed+=playerVSpeed*0.1*dt;
    
    playerSprite.wy-=playerVSpeed;
    if (playerSprite.wy >= screenHeight-1) { holdingJump = false; playerSprite.wy = (int)screenHeight-1; playerVSpeed = 0; playerJumping = false; }
  } else {
    playerVSpeed-=0.004*dt;
    if (playerVSpeed > 3) playerVSpeed = 3;
    
    playerSprite.wy-=playerVSpeed;
    if (playerSprite.wy >= screenHeight-1) { playerSprite.wy = screenHeight-1; playerVSpeed = 0; }

  }
}

void draw() {
  st = millis();

  background(0);
  
  inputHandler();
  physics();
  
  renderGame();
  renderEditor();
  
  et = millis();
  dt = et-st;
}
