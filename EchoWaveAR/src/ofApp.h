#pragma once

#include "ofxiOS.h"
#include <ARKit/ARKit.h>
#include "ofxARKit.h"


//#import <AVFoundation/AVFoundation.h>


class ofApp : public ofxiOSApp{
    
public:
    
    ofApp (ARSession * session);
    ofApp();
    ~ofApp ();

    
    
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
    
    int numWidth;
    int numHeight;
    float plateWidth;
    float plateHeight;
    
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

    
    ofVbo vbo;
    
    vector < matrix_float4x4 > mats;
    ofCamera camera;

    
    // ====== AR STUFF ======== //
    ARSession * session;
    ARCore::AnchorManagerRef anchors;
    ARRef processor;

    /*
     int32_t cameraWidth;
     int32_t cameraHeight;
     
     */

    
};


