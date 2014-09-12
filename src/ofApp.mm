#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){
    
    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofSetFrameRate(60);
    
    ofxAccelerometer.setup();               //accesses accelerometer data
    ofxiPhoneAlerts.addListener(this);      //allows elerts to appear while app is running
	ofRegisterTouchEvents(this);            //method that passes touch events
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    ofBackground(10, 255);
    
    ofSetDepthTest(true);
    
    
    left.clear();
    volHistory.clear();
    //
    numHeight = 256;
    
	bufferSize = 128;
    initialBufferSize = 128;
	sampleRate = 44100;
    
    
	left.assign(bufferSize, 0.0);
    //	right.assign(bufferSize, 0.0);
	volHistory.assign(numHeight, 0.0);
	
	bufferCounter	= 0;
	drawCounter		= 0;
	smoothedVol     = 0.0;
	scaledVol		= 0.0;
    
    buffer = new float[initialBufferSize];
	memset(buffer, 0, initialBufferSize * sizeof(float));
    volHistory.push_back( scaledVol );
    
	ofSoundStreamSetup(0, 1, this, sampleRate, initialBufferSize, 1);

    
    
    mesh.setMode(OF_PRIMITIVE_TRIANGLES);
    
    numWidth = 180;
    numHeight = 80;
    vertexSpacing = 10;
    
    plateWidth = (numWidth-1) * vertexSpacing;
    plateHeight = (numHeight-1) * vertexSpacing;
    
    zSize = 60;
    
    float _xRandom = ofRandom(24,48);
    float _yRandom = ofRandom(24,48);

    for (int j=0; j<numHeight; j++) {
        for (int i=0; i<numWidth; i++) {
            ofVec3f _a = ofVec3f( i * vertexSpacing - plateWidth/2, j * vertexSpacing - plateHeight/2, 0 );
            mesh.addVertex(_a);
            ofColor _c = ofColor::fromHsb(0, 120, 255, 255);
            mesh.addColor( _c );
            

            float _movingSpeed = 0.5;
            
            // _noise wird als zPosition Ÿbersetzt. (0-1)
            float _noise = ofNoise( i/_xRandom, j/_yRandom ) * zSize;
            
            if (_noise>zSize/2) {
                zPos.push_back( zSize-_noise );
                zDirection.push_back( -_movingSpeed );
            } else {
                zPos.push_back( _noise );
                zDirection.push_back( _movingSpeed );
            }
        }
    }
    
    for (int j=0; j<numHeight-1; j++) {
        for (int i=0; i<numWidth-1; i++) {
            
            int _index = i + j * numWidth;
            
            mesh.addIndex(_index);
            mesh.addIndex(_index+numWidth);
            mesh.addIndex(_index+1);
            
            mesh.addIndex(_index+1);
            mesh.addIndex(_index+numWidth);
            mesh.addIndex(_index+numWidth+1);
            
        }
    }
    
    cam.setupPerspective();
    
}

//--------------------------------------------------------------
void ofApp::update(){
    
    scaledVol = ofMap(smoothedVol, 0.0, 0.17, 0.0, 30.0, true);
    volHistory.push_back( scaledVol );
	
    if( volHistory.size() >= numHeight ){
		volHistory.erase(volHistory.begin(), volHistory.begin()+1);
	}

    
    for (int j=0; j<numHeight; j++) {
        for (int i=0; i<numWidth; i++) {
            int _index = i + j * numWidth;
            
            zPos[_index] = zPos[_index] + zDirection[_index];
            if (zPos[_index]>zSize/2) zDirection[_index] = -zDirection[_index];
            if (zPos[_index]<0) zDirection[_index] = -zDirection[_index];
            
        }
    }
    
    for (int j=0; j<numHeight; j++) {
        for (int i=0; i<numWidth; i++) {
            int _index = i + j * numWidth;
            
            ofVec3f _vec = mesh.getVertex(_index);
            mesh.setVertex( _index, ofVec3f( _vec.x, _vec.y, zPos[_index] * volHistory[i] ));
            
        }
    }
    
}

//--------------------------------------------------------------
void ofApp::draw(){

    cam.begin();
    
    ofRotateX(82);
    ofRotateY(0);
    ofRotateZ(270);
    
    for (int j=0; j<numHeight; j++) {
        for (int i=0; i<numWidth; i++) {
            int _index = i + j * numWidth;
            mesh.setColor( _index, ofColor::fromHsb(0,0,255,255) );
        }
    }

    mesh.draw();

    for (int j=0; j<numHeight; j++) {
        for (int i=0; i<numWidth; i++) {
            int _index = i + j * numWidth;
            mesh.setColor( _index, ofColor::fromHsb(0,0,0,255) );
        }
    }
    
    mesh.drawWireframe();
    
    cam.end();
    
}


void ofApp::audioIn(float * input, int bufferSize, int nChannels){
	
	float curVol = 0.0;
	int numCounted = 0;
    
	for (int i = 0; i < bufferSize; i++){
		left[i]		= input[i];        
		curVol += left[i] * left[i];
		numCounted+=2;
	}
	
	curVol /= (float)numCounted;
	curVol = sqrt( curVol );
	
	smoothedVol *= 0.93;
	smoothedVol += 0.07 * curVol;
	
	bufferCounter++;
	
}



void ofApp::exit(){
    
}


//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
}


//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){

}


//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void ofApp::lostFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotFocus(){
    
}

//--------------------------------------------------------------
void ofApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void ofApp::deviceOrientationChanged(int newOrientation){
    
}