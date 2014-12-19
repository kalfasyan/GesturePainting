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
 
 /*---------------------------------------------------------------
Paint Cursor
---------------------------------------------------------------*/
void paintCursor(PVector pos, color fillColor, color strokeColor){
//  g.beginDraw();
//  g.background(51);
  stroke(strokeColor);
  fill(fillColor);
  ellipse(pos.x,pos.y, 20,20);
//  g.endDraw();
//  image(g,pos.x,pos.y);
}

void paintCursor2(PVector pos, color fillColor, color strokeColor, PGraphics layer) {
  layer.beginDraw();
  layer.background(100);
  layer.stroke(strokeColor);
  layer.fill(fillColor);
  layer.ellipse(pos.x, pos.y, 20, 20);
//  g.line(20,20, pos.x, pos.y);
  layer.endDraw();
  image(g,pos.x,pos.y);
}


 
  
}
