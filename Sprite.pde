class Sprite {
  
  Frame[] frames;
  
  int ox;
  int oy;
  int ow;
  int oh;
  
  int wx;
  int wy;
  int framecount;
  
  Sprite(int _ox, int _oy, int _ow, int _oh, int _wx, int _wy, int _framecount) {

    ox = _ox;
    oy = _oy;
    ow = _ow;
    oh = _oh;
    wx = _wx;
    wy = _wy;
    framecount = _framecount;
    
    frames = new Frame[framecount];
    
    for (int i = 0; i < framecount; i++) {
      frames[i] = new Frame();
      frames[i].x = ox + (i*ow);
      frames[i].y = oy;
      frames[i].w = ow;
      frames[i].h = oh;
    }
  }
  
  Frame getFrame(int frameIndex) {
    return frames[frameIndex];
  }
}
