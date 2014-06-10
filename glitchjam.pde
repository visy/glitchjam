/* @pjs preload="tilemapsmall.png"; */

PImage tilemap;
PImage[] tiles;

int[] screenBG;

int tilemapWidth;
int tilemapHeight;

int screenWidth = 40;
int screenHeight = 28;

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
int playerX;
int playerY;
float playerXS = 0.0;

int showTilemap = 1;
int editormode = EDITORMODE_EDIT;

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
  
  levelBG = new ArrayList<Sprite>();
  
}

void resetPlayerToStart() {
  worldX = 0; 
  worldY = 0; 
  playerX = 10; 
  playerY = 0;
}

void setupGame() {
  resetPlayerToStart();
  screenBG = new int[screenWidth*screenHeight];
  for (int i = 0; i < screenWidth*screenHeight; i++) screenBG[i] = 0;
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
  if (editormode == EDITORMODE_EDIT && showTilemap == 1) text("editor - tile picker",0,8);
  if (editormode == EDITORMODE_EDIT && showTilemap == -1) text("editor - world",0,8);
  if (editormode == EDITORMODE_TEST) text("play test",0,8);
  if (editormode == EDITORMODE_PLAY) text("play - insert GUI here",0,8);

  if (editormode == EDITORMODE_EDIT && showTilemap == -1) {
    drawFrame((int)(width/8)-gridW, 0, gridFrame);
  }
}

void drawLevel() {
  for (int y = 0; y < screenHeight; y++) {
    for (int x = 0; x < screenWidth; x++) {
      drawTileNum(x,y+1,screenBG[(y*screenWidth)+x]);
    }
  }
}

void drawPlayer() {

}

void renderGame() {
  //playerX+=playerXS;
  drawLevel();
  //drawPlayer();  
}

void keyPressed() {
  if (key == ' ') showTilemap = -showTilemap;
  if (key == 't') { editormode = EDITORMODE_TEST; playerX = worldX; playerY = 0; }
  if (key == 'p') { editormode = EDITORMODE_PLAY; resetPlayerToStart(); }
  if (key == 'e') { editormode = EDITORMODE_EDIT; showTilemap = -1; }
/*
  if (key == 'w') { if (scrollY > 0) scrollY--; }
  if (key == 's') { if (scrollY < mapHeight-1) scrollY++; }
  if (key == 'a') { if (scrollX > 0) scrollX--; }
  if (key == 'd') { if (scrollX < mapWidth-1) scrollX++;}
*/

  if (key == CODED) {
    if (keyCode == UP) {
      gridY-=gridH;
      if (gridY < 1) gridY = 1;
    }
    if (keyCode == DOWN) {
      gridY+=gridH;
      if (gridY+gridH > (int)(tilemap.height/8)-6) gridY = (int)(tilemap.height/8)-7;
    }
    if (keyCode == LEFT) {
      gridX-=gridW;
      if (gridX < 0) gridX = 0;
    }
    if (keyCode == RIGHT) {
      gridX+=gridW;
      if (gridX+gridW > (int)(tilemap.width/8)) gridX = (int)(tilemap.width/8);
    }

  }
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
 
  if (editormode == EDITORMODE_EDIT && showTilemap != 1) {
    pScreenX = screenX;
    pScreenY = screenY;
    screenX = (int)(mouseX/8);
    screenY = (int)(mouseY/8);
    if (screenY <= 0) screenY = 1;
    if (screenY >= screenHeight) screenY = screenHeight;

    if (pScreenX != screenX) addedBlock=false;
    if (pScreenY != screenY) addedBlock=false;

    if (mousePressed == true && addedBlock == false) {
      for (int y = 0; y < gridFrame.h; y++) {
        for (int x = 0; x < gridFrame.w; x++) {
          screenBG[((screenY+y-1)*screenWidth)+(screenX+x)] = ((y+gridFrame.y)*tilemapWidth)+(x+gridFrame.x);
        }
      }
      addedBlock = true;
    }
    
    if (mousePressed == false) {
      addedBlock = false;
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

void draw() {
  background(0);
  
  inputHandler();
  
  renderGame();
  renderEditor();
}
