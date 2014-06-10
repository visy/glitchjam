class Undoable {
  Frame frame;
  int layer;
  int sx;
  int sy;
  int[] savedBlock;
  int tileCount;
  
  Undoable(Frame f, int l, int _sx, int _sy, int[] sb, int numTiles) {
    frame = new Frame();
    frame.x = f.x;
    frame.y = f.y;
    frame.w = f.w;
    frame.h = f.h;
    layer = l;
    sx = _sx;
    sy = _sy;
    
    tileCount = numTiles;
    
    savedBlock = new int[numTiles];
    for (int i = 0; i < numTiles; i++) 
    savedBlock[i] = sb[i];
  }
}
