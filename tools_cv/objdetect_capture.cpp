#include <opencv2/objdetect/objdetect.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/video/video.hpp>

#include <opencv/cv.h>
#include <opencv/highgui.h>

#include <iostream>
#include <stdio.h>
#include <time.h>
#include <ctime>
using namespace std;
using namespace cv;

/** Function Headers */
void detectAndDisplay( Mat frame );

/** Global variables */
String face_cascade_name = "haarcascade_frontalface_alt.xml";
CascadeClassifier face_cascade;
string window_name = "Capture - Face detection";
RNG rng(12345);

/** @function main */
int main( int argc, const char** argv )
{
  CvCapture* capture;
  IplImage* ipl_frame;
  Mat frame;

  //-- 1. Load the cascades
  if( !face_cascade.load( face_cascade_name ) ){ printf("--(!)Error loading\n"); return -1; };
  
  ipl_frame= cvLoadImage( "capture.jpg" , 1|CV_LOAD_IMAGE_ANYDEPTH );
  frame = cvarrToMat( ipl_frame );

  //-- 3. Apply the classifier to the frame
  if( !frame.empty() )
  { detectAndDisplay( frame ); }
  else
  { printf(" --(!) No captured frame -- Break!"); }
      
  cvWaitKey(0);

  return 0;
 }

/** @function detectAndDisplay */
void detectAndDisplay( Mat frame )
{
  std::vector<Rect> faces;
  Mat frame_gray;

  cvtColor( frame, frame_gray, CV_BGR2GRAY );
 
  equalizeHist( frame_gray, frame_gray );

  //-- Detect faces
  face_cascade.detectMultiScale( frame_gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, Size(30, 30) );

  for( size_t i = 0; i < faces.size(); i++ ) 
  { 
    Point center( faces[i].x + faces[i].width*0.5, faces[i].y + faces[i].height*0.5 );
    ellipse( frame, center, Size( faces[i].width*0.5, faces[i].height*0.5), 0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );

    Mat faceROI = frame_gray( faces[i] );
    std::vector<Rect> eyes;

  } 

  //-- Show what you got
  imshow( window_name, frame );

 }
