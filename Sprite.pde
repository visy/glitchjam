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
  
  int sfl;
  int efl;
  int sfr;
  int efr;
  
  void setAnimationLeft(int startFrame, int endFrame) {
    sfl = startFrame;
    efl = endFrame;
    animframe = 0;
  }
  void setAnimationRight(int startFrame, int endFrame) {
    sfr = startFrame;
    efr = endFrame;
    animframe = 0;
  }
  
  int animframe = 0;
  int animtimer = 0;
  int dir = 0;
  
  void setDir(int d) {
    dir = d;
  }
  
  void animate(int animspeed, float dt) {
    
    animtimer+=(int)dt;
    if (animtimer > animspeed) { animtimer = 0; animframe++; }
    if (animframe > 1) animframe = 0;
  }
  
  Frame getAnimFrame() {
    int i = 0;
    if (dir == 0) i = sfl+animframe;
    else if (dir == 1) i = sfr+animframe;
    
    return frames[i];
  }
  
  Frame getFrame(int frameIndex) {
    return frames[frameIndex];
  }
}
