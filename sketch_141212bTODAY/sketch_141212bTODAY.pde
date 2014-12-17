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
color[] userColor = new color[]{ color(255,0,0), color(0,255,0), color(0,0,255),
                                 color(255,255,0), color(255,0,255), color(0,255,255)};
 
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
PGraphics b1;
int b1x = 5;
int b1y = 5;
int bwidth = 50;
int bheight = 50;
PGraphics c;


/*---------------------------------------------------------------
Starts new kinect object and enables skeleton tracking.
Draws window
----------------------------------------------------------------*/
void setup()
{
  b1 = createGraphics(bwidth,bheight);
  c = createGraphics(bwidth,bheight);
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
void draw(){ 
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
  for(int i=0;i<userID.length;i++)
  {
    
    // if Kinect is tracking certain user then get joint vectors
    if(kinect.isTrackingSkeleton(userID[i]))
    {
      // get confidence level that Kinect is tracking head
      confidence = kinect.getJointPositionSkeleton(userID[i],
                          SimpleOpenNI.SKEL_HEAD,confidenceVector);
 
      // if confidence of tracking is beyond threshold, then track user
      paintCursor(userID[i]);
      if(confidence > confidenceLevel)
      {
        // change draw color based on hand id#
        stroke(userColor[(i)]);
        // fill the ellipse with the same color
        fill(userColor[(i)]);
        // draw the rest of the body
        //drawSkeleton(userID[i]);
        // **************************
        paintButtons();
        
        int buttonNumber = checkButton(userID[i]);
        if (buttonNumber == 1){
          fill(0);
        }        
        paintStuff(userID[i]);
 
      } //if(confidence > confidenceLevel)
    } //if(kinect.isTrackingSkeleton(userID[i]))
  } //for(int i=0;i<userID.length;i++)
} // void draw()

/*---------------------------------------------------------------
Check if our left hand is over a button
----------------------------------------------------------------*/
int checkButton(int userId){
  if (overButton(b1x,b1y,bwidth,bheight,userId)){
    return 1;
  } else {
    return 0;
  }
}
/*---------------------------------------------------------------
OverButton
----------------------------------------------------------------*/
boolean overButton(int x, int y, int w, int h,int userId){
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHandPos);
  kinect.convertRealWorldToProjective(leftHandPos,leftHandPos); 
  float a = leftHandPos.x;
  float b = leftHandPos.y;
  
  if ( a >= x && a<= x+w && b >= y && b <= y+h ){
    return true;
  } else {
    return false;
  }
}
 
 
/*---------------------------------------------------------------
Painting
----------------------------------------------------------------*/
 void paintStuff(int userId){
   
   
   kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHandPos);
   kinect.convertRealWorldToProjective(rightHandPos,rightHandPos); 
   println(rightHandPos.x);
   println(rightHandPos.y);
   
   ellipse(rightHandPos.x,rightHandPos.y, 20,20);
   
   
}
/*---------------------------------------------------------------
Paint Buttons
---------------------------------------------------------------*/
void paintButtons(){
   b1.beginDraw();
   b1.background(51);
   b1.noFill();
   b1.stroke(255);
   b1.rect(0,0,bwidth,bheight);
   b1.endDraw();
   image(b1,b1x,b1y);   
}
/*---------------------------------------------------------------
Paint Cursor
---------------------------------------------------------------*/
void paintCursor(int userId){
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHandPos);
  kinect.convertRealWorldToProjective(leftHandPos,leftHandPos); 
  c.beginDraw();
  c.background(51);
  c.rect(0,0,bwidth,bheight);
  c.endDraw();
  image(c,leftHandPos.x,leftHandPos.y);

}


/*---------------------------------------------------------------
Draw the skeleton of a tracked user.  Input is userID
----------------------------------------------------------------*/
void drawSkeleton(int userId){
  
   // get 3D position of head
  kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_HEAD,headPosition);
  // convert real world point to projective space
  kinect.convertRealWorldToProjective(headPosition,headPosition);
  // create a distance scalar related to the depth in z dimension
  distanceScalar = (525/headPosition.z);
  // draw the circle at the position of the head with the head size scaled by the distance scalar
  ellipse(headPosition.x,headPosition.y, distanceScalar*headSize,distanceScalar*headSize); 
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
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP,  SimpleOpenNI.SKEL_LEFT_KNEE);
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
void onNewUser(SimpleOpenNI curContext, int userId){
  println("New User Detected - userId: " + userId);
  // start tracking of user id
  curContext.startTrackingSkeleton(userId);
} //void onNewUser(SimpleOpenNI curContext, int userId)
 
/*---------------------------------------------------------------
Print when user is lost. Input is int userId of user lost
----------------------------------------------------------------*/
void onLostUser(SimpleOpenNI curContext, int userId){
  // print user lost and user id
  println("User Lost - userId: " + userId);
} //void onLostUser(SimpleOpenNI curContext, int userId)
 
/*---------------------------------------------------------------
Called when a user is tracked.
----------------------------------------------------------------*/
void onVisibleUser(SimpleOpenNI curContext, int userId){
} //void onVisibleUser(SimpleOpenNI curContext, int userId)
