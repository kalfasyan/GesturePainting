/*---------------------------------------------------------------
 Created by: Leonardo Merza
 Version: 1.0
 
 This class will track skeletons of users and draw them
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

//*****************************************
PVector leftHandPos = new PVector();
PVector rightHandPos = new PVector();
float distanceScalarLHand;
float leftHandSize = 50;
float rightHandSize = 50;
PImage canvas;
//PGraphics b1;
Button redB;
Button greenB;
Button blueB;
Button[] allButtons;
int b1x = 5;
int b1y = 5;
int bwidth = 100;
int bheight = 80;
int brushW = 20;
int brushH = 20;
int cursorW = 20;
int cursorH = 20;

/** Some Colors to play with **/
color red = color(230, 25, 44);
color green = color(127, 255, 0);
color blue = color(52,152,219);
color yellow = color(232, 222, 42);
color orange = color(255, 118, 25);
color purple = color(156, 138, 165); 
color gray = color(127, 140, 141);
color white = color(255, 255, 255);
color black = color(0, 0, 0);
color transparent = color (255,0,0,0);

int[] allColors = new color[] {black, white, red, green, blue, yellow, orange, purple, gray};  // color ids are respectively 0, 1, 2, ...., 8

color currentFillColor;
color currentStrokeColor; //not used for the moment
color brushColor = green;
color strokeColor = color(255, 0, 0, 0);

PGraphics c;
Cursor brush, leftC;

/*---------------------------------------------------------------
 Starts new kinect object and enables skeleton tracking.
 Draws window
 ----------------------------------------------------------------*/
void setup()
{  
  //b1 = createGraphics(bwidth, bheight);
  Button redB = new Button(5,5+bheight, bwidth, bheight, 2, red);
  Button greenB = new Button(5, 5+2*bheight, bwidth, bheight, 3, green);
  Button blueB = new Button(5, 5+3*bheight, bwidth, bheight, 4, blue);
  Button yellowB = new Button(5, 5+4*bheight, bwidth, bheight, 5, yellow);
  Button orangeB = new Button(5, 5+5*bheight, bwidth, bheight, 6, orange);
  Button purpleB = new Button(5, 5+6*bheight, bwidth, bheight, 7, purple);
  Button grayB = new Button(5, 5+7*bheight, bwidth, bheight, 8, gray);
  allButtons = new Button[] {redB, greenB, blueB, yellowB, orangeB, purpleB, grayB}; 
  currentFillColor = red;
  currentStrokeColor = transparent;
  
  
  // create brush
  brush = new Cursor(brushW, brushH);
  // create cursor for left hand
  leftC = new Cursor(cursorW, cursorH);
  
  
  
//  c = createGraphics(bwidth, bheight);

  background(255);
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

  
} // void setup()

/*---------------------------------------------------------------
 Updates Kinect. Gets users tracking and draws skeleton and
 head if confidence of tracking is above threshold
 ----------------------------------------------------------------*/
void draw() { 
  //******************

  // update the camera
  kinect.update();
  // get Kinect data
  kinectDepth = kinect.depthImage();
  // draw depth image at coordinates (0,0)
  // INSTEAD OF KINETDEPTH TRY SOMETHING ELSE
  //image(kinectDepth,0,0);
  // get all user IDs of tracked users
  userID = kinect.getUsers();

  // loop through each user to see if tracking
  for (int i=0; i<userID.length; i++)
  {

    // if Kinect is tracking certain user then get joint vectors
    if (kinect.isTrackingSkeleton(userID[i]))
    {
      

      // get confidence level that Kinect is tracking head
      confidence = kinect.getJointPositionSkeleton(userID[i], 
      SimpleOpenNI.SKEL_HEAD, confidenceVector);

      // if confidence of tracking is beyond threshold, then track user
      //paintCursor(userID[i]);
      if (confidence > confidenceLevel)
      {
        // get left hand position
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
        kinect.convertRealWorldToProjective(leftHandPos, leftHandPos);
        // get right hand position
        kinect.getJointPositionSkeleton(userID[i], SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
        kinect.convertRealWorldToProjective(rightHandPos, rightHandPos);
        // change draw color based on hand id#
        // fill the ellipse with the same color
        // no need to do that here but keep the command, we will use it later
        //stroke(userColor[(i)]);
        //noStroke();
        // the 4th value is the transparency
        //fill(255, 0, 0, 127);

        // draw the rest of the body
        //drawSkeleton(userID[i]);
        // ************************** 
        leftC.paintCursor(leftHandPos, white, black);
        brush.paintCursor(rightHandPos, currentFillColor, currentStrokeColor);
        paintButtons();
                
//        redB.paintButton();
//        blueB.paintButton();
//        greenB.paintButton();

        int buttonNumber = checkButton(leftHandPos);
        if (buttonNumber <= allColors.length) {          
          changeFillColor(buttonNumber);
        }        
        //paintStuff(userID[i]);
        
      } //if(confidence > confidenceLevel)
    } //if(kinect.isTrackingSkeleton(userID[i]))
  } //for(int i=0;i<userID.length;i++)
} // void draw()

/*------------------------------------------------------------------------------
 Checks if our left hand is over any button. Returns the id of the button, else 0
 -------------------------------------------------------------------------------*/
int checkButton(PVector pos) {
  for (int i=0; i<allButtons.length; i++) {
    if (allButtons[i].overButton(pos)) {
      return allButtons[i].id;
    }
  }
  return 1000;
  
//  if (overButton(b1x, b1y, bwidth, bheight, userId)) {
//    return 1;
//  } else {
//    return 0;
//  }
}
/*---------------------------------------------------------------
Change functions. E.g. changeFillColor -> changes the color of the brush 
 ----------------------------------------------------------------*/
 
//void changeFillColor (color c) {
//  currentFillColor = c;
//}

void changeFillColor (int colorID) {
  currentFillColor = allColors[colorID];
}

void changeStrokeColor(color c) {
  currentStrokeColor = c;
}


/*---------------------------------------------------------------
 OverButton
 ----------------------------------------------------------------*/
//boolean overButton(int x, int y, int w, int h, int userId) {
//  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
//  kinect.convertRealWorldToProjective(leftHandPos, leftHandPos); 
//  float a = leftHandPos.x;
//  float b = leftHandPos.y;
//
//  if ( a >= x && a<= x+w && b >= y && b <= y+h ) {
//    return true;
//  } else {
//    return false;
//  }
//}


/*---------------------------------------------------------------
 Painting
 ----------------------------------------------------------------*/
void paintStuff(int userId) {


  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);
  kinect.convertRealWorldToProjective(rightHandPos, rightHandPos); 
  println(rightHandPos.x);
  println(rightHandPos.y);

  ellipse(rightHandPos.x, rightHandPos.y, 20, 20);
}
/*---------------------------------------------------------------
 Paint Buttons
 ---------------------------------------------------------------*/
void paintButtons() {
  for (int i=0; i<allButtons.length; i++) {
    allButtons[i].paintButton();
  }
//  b1.beginDraw();
//  b1.background(51);
//  b1.noFill();
//  b1.stroke(255);
//  b1.rect(0, 0, bwidth, bheight);
//  b1.endDraw();
//  image(b1, b1x, b1y);
}
/*---------------------------------------------------------------
 Paint Cursor
 ---------------------------------------------------------------*/
void paintCursor(int userId) {
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHandPos);
  kinect.convertRealWorldToProjective(leftHandPos, leftHandPos); 
  c.beginDraw();
  c.background(51);
  c.rect(0, 0, bwidth, bheight);
  c.endDraw();
  image(c, leftHandPos.x, leftHandPos.y);
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

