#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"

//#import <AVFoundation/AVFoundation.h>


class ofApp : public ofxiOSApp{
    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    
    ofMesh mesh;
    
    ofEasyCam cam;
    
    vector<float> zPos;
    vector<float> zDirection;
    
    int numWidth, numHeight;
    float plateWidth, plateHeight;
    
    int vertexSpacing;
    
    float zSize;
    
    
    // Audio Beispiele kommt von "audioInputExample"
    int bufferSize;
    void audioIn(float * input, int bufferSize, int nChannels);
    
    vector <float> left;
    vector <float> right;
    vector <float> volHistory;
    
    int 	bufferCounter;
    int 	drawCounter;
    
    float smoothedVol;
    float scaledVol;
    
//    ofSoundStream soundStream;
	int	initialBufferSize;
	int	sampleRate;
    float * buffer;

    
};


