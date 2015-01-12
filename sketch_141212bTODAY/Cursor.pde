//class representing a cursor (left or right hand)

class Cursor {
  int w;       // width
  int h;       // height 
  int type;     // 1 for rectangle, 2 for ellipse, +++ we can add more stuff here. Say default is 2                 
  
  Cursor(int cw, int ch) {
    w = cw;
    h = ch;
    g = createGraphics(w,h);
  }
  
  /*----------------------------------------------------------------
  Cursor set and get size
  ----------------------------------------------------------------*/
  
  //Set the size of the cursor
  void setSize(int nw, int nh) {
    w = nw;
    h = nh;
  }
  
  //Get cursow width
  int getWidth() {
    return w;
  }
  
  //Get cursor height
  int getHeight() {
    return h;
  }
 
   /*---------------------------------------------------------------
  Paint Cursor
  ---------------------------------------------------------------*/
  
  // This paintCursor function LEAVES A TRACE
  // Receiving (PGraphics g) as argument, makes the trace
  void paintCursor(PVector pos, color fillColor, color strokeColor, PGraphics g){  
    g.beginDraw();
    g.noStroke();
    g.fill(fillColor);;
    g.ellipse(pos.x,pos.y, w,h);
    g.endDraw();
  }
  
  // This paintCursor function DOES NOT LEAVE A TRACE
  void paintCursor2(PVector pos, color fillColor, color strokeColor){
    g.beginDraw();
    g.noStroke();
    //g.fill(255,0,0);
    g.ellipse(pos.x, pos.y, 20,20);
    g.endDraw();
  }
  
  // This paintCursor function DOES NOT LEAVE A TRACE and paints an image instead of a shape
  void paintImageCursor(PVector pos, PImage img){
    g.beginDraw();
    image(img, pos.x, pos.y);
    g.endDraw();
  }
  
  void eraseFunction(PVector pos, PGraphics g){
    color c = color(0,0);
    g.beginDraw();
    g.loadPixels();
    for (int x=0; x<g.width; x++) {
      for (int y=0; y<g.height; y++ ) {
        float distance = dist(x,y,pos.x,pos.y);
        if (distance <= 25) {
          int loc = x + y*g.width;
          g.pixels[loc] = c;
        }
      }
    }
    g.updatePixels();
    g.endDraw();  
  }


}

