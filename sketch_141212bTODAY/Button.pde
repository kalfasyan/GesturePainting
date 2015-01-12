// class representing one button

class Button {
  
int posx;    // x position of upper left corner
int posy;    // y position of upper left corner
int w;       // button width
int h;       // button height
color c;     // button color // image i -> later probably each button will be represented by an image/icon
int id;      // button id
PGraphics g;
PImage img;

// other properties can be added here

/*
ctor
*/
Button(int bx, int by, int bw, int bh, int bid, color bc) {  
  posx = bx;
  posy = by;
  w = bw;
  h = bh;  
  id = bid; 
  c = bc;
  g = createGraphics(w, h);
}

Button(int bx, int by, int bw, int bh, int bid, PImage bimg) {  
  posx = bx;
  posy = by;
  w = bw;
  h = bh;  
  id = bid; 
  img = bimg;
  g = createGraphics(w, h);
}

/*
Checks if position in params is over the button
*/
boolean overButton(PVector position){    
  
  if ( position.x >= posx && position.x <= posx+w && position.y >= posy && position.y <= posy+h ){
    return true;
  } else {
    return false;
  }
}

/*
Paints the button
*/
void paintButton(){
   g.beginDraw();
   g.background(0);
   g.fill(c);
   g.noStroke();
   //g.noFill();
   //g.stroke(b);
   g.rect(0,0,w,h,5);
   g.endDraw();
   image(g,posx,posy);   
}

/*
Paints the button's image
*/
void paintImageButton(){
   g.beginDraw();
   g.image(img, posx, posy);
   g.endDraw();
   image(img,posx,posy);   
}

}



