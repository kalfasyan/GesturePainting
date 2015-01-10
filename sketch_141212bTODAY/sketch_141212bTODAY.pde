/*---------------------------------------------------------------
TASKS //add every task to be done here

For Milestone:
OK Implement left hand - push/hover button property
OK Don't change color only when cursor is hovering, once it touches the button it changes and stays that way.
*  Left hand cursor has to be drawn as a cursor, not painting
OK Menu on the left: 6-color palette - each color is picked on hover of the left hand.
OK  Maybeimplement the same thing for cursor input, for debugging reasons. --> PVector mouse added. 
*  Try at least one gesture --> Implement checkLeftArm();

Basic Tasks:
* Hover selection is a bit difficult, maybe add a gesture for selecting? (simulating a mouse click)
* Start / Stop Drawing : !!! RECOGNIZE GESTURE OF LEFT HAND FOR THAT
* Implement background : Show the camera input instead of a blank paper
* Basic Menu on the left:
  * Tool 1 - Brush stroke button(light, normal, bold)
  * Tool 2 - Eraser button
  * Tool 3 - Color Picker button(first choose between 6 colors)
  * Tool 4 - What else?

Additional Tasks: (Add what you want here, some cool stuff, everyone can pick one or more and implement it)
* Transparency
* Add tracking of more users
 ----------------------------------------------------------------*/

/*---------------------------------------------------------------
 Imports
 ----------------------------------------------------------------*/
// import kinect library
import SimpleOpenNI.*;

/*---------------------------------------------------------------
 Variables
 ----------------------------------------------------------------*/
// create kinect object
SimpleOpenNI  kinect;
// image storage from kinect
PImage kinectDepth;
// int of each user being  tracked
int[] userID;
// user colors
color[] userColor = new color[] { 
  color(255, 0, 0), color(0, 255, 0), color(0, 0, 255), 
  color(255, 255, 0), color(255, 0, 255), color(0, 255, 255)
};

int windowWidth = 800;
int windowHeight = 800;

// postion of head to draw circle
PVector headPosition = new PVector();
// turn headPosition into scalar form
float distanceScalar;
// diameter of head drawn in pixels
float headSize = 200;

// threshold of level of confidence
float confidenceLevel = 0.5;
// the current confidence level that the kinect is tracking
float confidence;
// vector of tracked head for confidence checking
PVector confidenceVector = new PVector();

// vector of tracked hand positions (use .x, .y for coordinates)
PVector leftHandPos = new PVector();
PVector rightHandPos = new PVector();

//Use this PVector inside draw function to simulate hand with mouse
//PVector mouse = new PVector(mouseX, mouseY);

float distanceScalarLHand;
float leftHandSize = 50;
float rightHandSize = 50;
PGraphics canvas;
//All Buttons
Button redB;
Button greenB;
Button blueB;
Button yellowB;
Button orangeB;
Button purpleB;
Button grayB;
Button eraserB;
Button sizeB;
Button[] allButtons;

//position of first button
int blx = int(windowWidth * 0.06);
int bly = int(windowHeight * 0.06);

//button spacing
int bspace = 4;

//button size
int bwidth = 40;
int bheight = 40;
//brush size
int brushW = 20;
int brushH = 20;
//original cursor size
int cursorW = 20;
int cursorH = 20;

//Cursor sizes
int big = 40;
int small = 20;

boolean changedSize = false;

boolean paintOn = false;
boolean changedPaintingStatus = false;

/** Some Colors to play with **/
color red = color(230, 25, 44);
color green = color(127, 255, 0);
color blue = color(52,152,219);
color yellow = color(232, 222, 42);
color orange = color(255, 118, 25);
color purple = color(156, 0, 165); 
color gray = color(127, 140, 141);
color white = color(255, 255, 255);
color black = color(0, 0, 0);
color transparent = color (255,0,0,0);

int[] allColors = new color[] {black, white, red, green, blue, yellow, orange, purple, gray, transparent};  // color ids are respectively 0, 1, 2, ...., 8

// value for the fill/stroke color used by the brush. Change this value to change the brush fill/stroke color
color currentFillColor;
color currentStrokeColor; //not used for the moment

//color brushColor = green;
//color strokeColor = color(255, 0, 0, 0);

//PGraphics c;

//Declare cursors
Cursor brush, leftC;
PGraphics layer1;

/*---------------------------------------------------------------
 Starts new kinect object and enables skeleton tracking.
 Draws window
 ----------------------------------------------------------------*/
void setup()
{ 
  size(windowWidth,windowHeight);
  smooth();
  canvas = createGraphics(width,height,JAVA2D);
  canvas.beginDraw();
  canvas.smooth();
  
  //b1 = createGraphics(bwidth, bheight);
  Button redB = new Button(blx,bly, bwidth, bheight, 2, red);
  Button greenB = new Button(blx+bwidth+bspace, int(bly-0.5*bheight), bwidth, bheight, 3, green);
  Button blueB = new Button(blx+2*(bwidth+bspace),  int(bly-1.5*0.5*bheight), bwidth, bheight, 4, blue);
  Button yellowB = new Button(blx+3*(bwidth+bspace), int(bly-1.75*0.5*bheight), bwidth, bheight, 5, yellow);
  Button orangeB = new Button(int(blx-0.5*bwidth), bly+bheight+bspace, bwidth, bheight, 6, orange);
  Button purpleB = new Button(int(blx-1.5*0.5*bwidth), bly+2*(bheight+bspace), bwidth, bheight, 7, purple);
  Button grayB = new Button(int(blx-1.75*0.5*bwidth), bly+3*(bheight+bspace), bwidth, bheight, 8, gray);
  Button sizeB = new Button(int(blx-1.75*0.5*bwidth), bly+4*(bheight+2*bspace), bwidth, bheight, 9, white);
  Button eraserB = new Button(int(blx-1.75*0.5*bwidth), bly+5*(bheight+2*bspace), bwidth, bheight, 10, transparent);
  allButtons = new Button[] {redB, greenB, blueB, yellowB, orangeB, purpleB, grayB, sizeB, eraserB}; 
  currentFillColor = blue;
  currentStrokeColor = transparent;
  
  
  // create brush
  brush = new Cursor(brushW, brushH);
  // create cursor for left hand
  leftC = new Cursor(cursorW, cursorH);

  
  // start a new kinect object
  kinect = new SimpleOpenNI(this);

  // enable depth sensor
  kinect.enableDepth();

  // enable skeleton generation for all joints
  kinect.enableUser();
  kinect.enableHand();
  // draw thickness of drawer
  strokeWeight(3);
  // smooth out drawing
  smooth();

  // create a window the size of the depth information
  size(kinect.depthWidth(), kinect.depthHeight());
  layer1 = createGraphics(cursorW, cursorH);
  
  canvas.endDraw();  
  
} // void setup()

/*---------------------------------------------------------------
 Updates Kinect. Gets users tracking and draws skeleton and
 head if confidence of tracking is above threshold
 ----------------------------------------------------------------*/
void draw() { 
  background(255);
  noStroke();
  // In this 'for loop' we create the canvas color (now grey striped vertical lines)
  for (int i=0; i<10; i++) {
        fill(i*25+25);
        rect(i*width/10,0,width/10,height);
      }
  image(canvas,0,0);
  
  // update the camera
  kinect.update();
  // get Kinect data
  kinectDepth = kinect.depthImage();
  
  // draw depth image at coordinates (0,0)
  // INSTEAD OF KINETDEPTH TRY SOMETHING ELSE
  //image(kinectDepth,0,0);
  
  // get all user IDs of tracked users
  userID = kinect.getUsers();
  
  // paint buttons here (independent of user id's)
  paintButtons(); 

  // loop through each user to see if tracking
  // but if we care only for the first user then we shouldn't being doing that. 
  // Or maybe care only for one user, not caring about his id (e.g. the first minute it's user1, then user2 pops in and takes control)
  // In any case, this needs fixing --> BUG when detects 2nd user.  
  for (int i=0; i<userID.length; i++)
  {
    
    // if Kinect is tracking certain user then get joint vectors
    if (kinect.isTrackingSkeleton(userID[i]))
    {     
      
      // get confidence level that Kinect is tracking head
      confidence = kinect.getJointPositionSkeleton(userID[i], 
      SimpleOpenNI.SKEL_HEAD, confidenceVector);

      // if confidence of tracking is beyond threshold, then track user     
      if (confidence > confidenceLevel)
      {
        // get left hand position 
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
        kinect.convertRealWorldToProjective(leftHandPos, leftHandPos);
        // get right hand position
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
        kinect.convertRealWorldToProjective(rightHandPos, rightHandPos);
        
       
        // draw the rest of the body
        drawSkeleton(userID[i]);
        
        /* Check if the user placed their hand in front of (or theoretically also
        behind) their head. If they have, switch painting on/off
        */
        if (checkHeadTouch(headPosition, leftHandPos) && !changedPaintingStatus) {
          if (paintOn) {
            paintOn = false;
          } else {
            paintOn = true;
          }
          changedPaintingStatus = true;
        } else {
        changedPaintingStatus = false;
        }
        
        //Paint Cursors
        
        //leftC.eraseFunction(leftHandPos, canvas); // if you want to have left hand = eraser
        brush.paintCursor2(rightHandPos, transparent, black);
        leftC.paintCursor2(leftHandPos, transparent, black);
        //brush.paintCursor(rightHandPos, currentFillColor, currentStrokeColor);
        if (paintOn) {
          brush.paintCursor(rightHandPos, currentFillColor, currentStrokeColor, canvas);
        }
        
        int buttonNumber = checkButton(leftHandPos);
        if (buttonNumber <= 8) {          
          changeFillColor(buttonNumber);
        }
        //If touching size button, switch size
        //Checks changedSize to prevent size from rapidly changing while the
        //user hovers over the button. 
        if (buttonNumber == 9 && !changedSize){
          if (brush.getWidth() < 30) {
            brush.setSize(big, big);
          } else {
            brush.setSize(small, small);
          }
          changedSize = true;
        }  
        if (buttonNumber == 10){
          brush.eraseFunction(rightHandPos,canvas);
        }
        // No button is touched, reset brush size boolean
        if (buttonNumber == 1000) {
          changedSize = false;
        }    
        
        
        
      } //if(confidence > confidenceLevel)
    } //if(kinect.isTrackingSkeleton(userID[i]))
  } //for(int i=0;i<userID.length;i++)
} // void draw()



/*---------------------------------------------------------------------------------------
 Checks if pos in parameters is over any button. Returns the id of the button, else 1000
 ---------------------------------------------------------------------------------------*/
int checkButton(PVector pos) {
  for (int i=0; i<allButtons.length; i++) {
    if (allButtons[i].overButton(pos)) {
      return allButtons[i].id;
    }
  }
  return 1000;

}
/*----------------------------------------------------------------------------------------
Gesture Recognition
-----------------------------------------------------------------------------------------*/

//TODO
// Check if left hand is horizontal. This can be one gesture in order to start/stop painting/ 
//boolean checkLeftArm(PVector leftHPos, PVector leftElbowPos, PVector leftShoulderPos) {
//}

boolean checkHeadTouch(PVector headPos, PVector handPos) {
  if (handPos.x >= (headPos.x-25) && handPos.x <= (headPos.x+25)) {
    if (handPos.y >= (headPos.y-25) && handPos.y <= (headPos.y+25)) {
        return true;
    }
  }
  return false;
}

/*---------------------------------------------------------------
Change functions. E.g. changeFillColor -> changes the color of the brush 
 ----------------------------------------------------------------*/

void changeFillColor (int colorID) {
  currentFillColor = allColors[colorID];
}

void changeStrokeColor(color c) {
  currentStrokeColor = c;
}



/*-------------------------------------------------------------------------------------------
 Paint Buttons: paints all buttons. The buttons must be elements of the array allButtons[]
 ------------------------------------------------------------------------------------------*/
void paintButtons() {
  for (int i=0; i<allButtons.length; i++) {
    allButtons[i].paintButton();
  }
}

/*---------------------------------------------------------------
 Draw the skeleton of a tracked user.  Input is userID
 ----------------------------------------------------------------*/
void drawSkeleton(int userId) {

  // get 3D position of head
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD, headPosition);
  // convert real world point to projective space
  kinect.convertRealWorldToProjective(headPosition, headPosition);
  // create a distance scalar related to the depth in z dimension
  distanceScalar = (525/headPosition.z);
  // draw the circle at the position of the head with the head size scaled by the distance scalar
  ellipse(headPosition.x, headPosition.y, distanceScalar*headSize, distanceScalar*headSize); 
  //draw limb from head to neck
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
  //draw limb from neck to left shoulder
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  //draw limb from left shoulde to left elbow
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  //draw limb from left elbow to left hand
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
  //draw limb from neck to right shoulder
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  //draw limb from right shoulder to right elbow
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  //draw limb from right elbow to right hand
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
  //draw limb from left shoulder to torso
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //draw limb from right shoulder to torso
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  //draw limb from torso to left hip
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  //draw limb from left hip to left knee
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  //draw limb from left knee to left foot
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
  //draw limb from torse to right hip
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  //draw limb from right hip to right knee
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  //draw limb from right kneee to right foot
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
} // void drawSkeleton(int userId)

/*---------------------------------------------------------------
 When a new user is found, print new user detected along with
 userID and start pose detection.  Input is userID
 ----------------------------------------------------------------*/
void onNewUser(SimpleOpenNI curContext, int userId) {
  println("New User Detected - userId: " + userId);
  // start tracking of user id
  curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)

/*---------------------------------------------------------------
 Print when user is lost. Input is int userId of user lost
 ----------------------------------------------------------------*/
void onLostUser(SimpleOpenNI curContext, int userId) {
  // print user lost and user id
  println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)

/*---------------------------------------------------------------
 Called when a user is tracked.
 ----------------------------------------------------------------*/
void onVisibleUser(SimpleOpenNI curContext, int userId) {
} //void onVisibleUser(SimpleOpenNI curContext, int userId)















