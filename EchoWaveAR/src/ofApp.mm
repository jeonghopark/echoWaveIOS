#include "ofApp.h"
//#import <AVFoundation/AVFoundation.h>


//--------------------------------------------------------------
void logSIMD(const simd::float4x4 &matrix) {
    std::stringstream output;
    int columnCount = sizeof(matrix.columns) / sizeof(matrix.columns[0]);
    for (int column = 0; column < columnCount; column++) {
        int rowCount = sizeof(matrix.columns[column]) / sizeof(matrix.columns[column][0]);
        for (int row = 0; row < rowCount; row++) {
            output << std::setfill(' ') << std::setw(9) << matrix.columns[column][row];
            output << ' ';
        }
        output << std::endl;
    }
    output << std::endl;
    //NSLog(@"%s", output.str().c_str());
}


//--------------------------------------------------------------
ofMatrix4x4 matFromSimd(const simd::float4x4 &matrix){
    ofMatrix4x4 mat;
    mat.set(matrix.columns[0].x,matrix.columns[0].y,matrix.columns[0].z,matrix.columns[0].w,
            matrix.columns[1].x,matrix.columns[1].y,matrix.columns[1].z,matrix.columns[1].w,
            matrix.columns[2].x,matrix.columns[2].y,matrix.columns[2].z,matrix.columns[2].w,
            matrix.columns[3].x,matrix.columns[3].y,matrix.columns[3].z,matrix.columns[3].w);
    return mat;
}


//--------------------------------------------------------------
ofApp :: ofApp (ARSession * session){
    this->session = session;
    //    cout << "creating ofApp" << endl;
}


//--------------------------------------------------------------
ofApp::ofApp() {
    
}


//--------------------------------------------------------------
ofApp :: ~ofApp () {
    //    cout << "destroying ofApp" << endl;
}




//--------------------------------------------------------------
void ofApp::setup(){
    
    //    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    //    ofSetFrameRate(60);
    
    //    ofxAccelerometer.setup();               //accesses accelerometer data
    //    ofxiPhoneAlerts.addListener(this);      //allows elerts to appear while app is running
    //    ofRegisterTouchEvents(this);            //method that passes touch events
    
    //    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    //    ofBackground(10, 255);
    
    //    ofSetDepthTest(true);
    
    //    left.clear();
    //    volHistory.clear();
    
    processor = ARProcessor::create(session);
    processor->setup();
    
    anchors = ARCore::ARAnchorManager::create(session);
    
    anchors->addAnchor(ofVec2f(0, 0));
    
    
    numWidth = 256;
    numHeight = 256;
    
    bufferSize = 128;
    initialBufferSize = 128;
    sampleRate = 44100;
    ofSoundStreamSetup(0, 1, this, sampleRate, initialBufferSize, 4);
    
    
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
    
    
    vertexSpacing = 8;
    
    plateWidth = (numWidth-1) * vertexSpacing;
    plateHeight = (numHeight-1) * vertexSpacing;
    
    zSize = 60;
    
    float _xRandom = ofRandom(24, 48);
    float _yRandom = ofRandom(24, 48);
    
    for (int j=0; j<numHeight; j++) {
        for (int i=0; i<numWidth; i++) {
            ofVec3f _a = ofVec3f( i * vertexSpacing - 0, j * vertexSpacing - 0, 0 );
            mesh.addVertex(_a);
            ofColor _c = ofColor::fromHsb(0, 255, 255, 255);
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
    
    
    mesh.setMode(OF_PRIMITIVE_TRIANGLES);
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
    
    
    //    cam.setupPerspective();
    //    cam.setDistance(1000);
    
    
}




//--------------------------------------------------------------
void ofApp::update(){
    
    
    processor->update();
    
    mats.clear();
    
    anchors->update();
    
    
    scaledVol = ofMap(smoothedVol, 0.0, 0.17, 0.0, 30.0, true);
    volHistory.push_back( scaledVol );
    
    if( volHistory.size() >= numHeight ){
        volHistory.erase(volHistory.begin(), volHistory.begin()+1);
    }
    
    if (zPos.size() > 0 && zDirection.size() > 0) {
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
    
}

//--------------------------------------------------------------
void ofApp::draw(){
    
    ofEnableAlphaBlending();
    
    ofDisableDepthTest();
    processor->draw();
    ofEnableDepthTest();
    
    anchors->loopAnchors([=](ARObject obj) -> void {
        
        camera.begin();
        processor->setARCameraMatrices();
        
        ofPushMatrix();
        ofMultMatrix(obj.modelMatrix);
        
        ofSetColor(255);
        ofRotate(90,0,0,1);
        ofScale(0.001, 0.001, 0.001);

        
        
        ofPushMatrix();
        
        ofTranslate( 0, 0, 0 );
        ofRotateXDeg( -90 );
        ofRotateZDeg( 90 );
        
        ofPushStyle();

        mesh.drawWireframe();
        
        ofPopStyle();
        
        ofPopMatrix();
        
        
        
        ofPopMatrix();
        
        camera.end();
        
    
    });

    
    
}




void ofApp::audioIn(float * input, int bufferSize, int nChannels){
    
    float curVol = 0.0;
    int numCounted = 0;
    
    for (int i = 0; i < bufferSize; i++){
        left[i]		= input[i];
        curVol += left[i] * left[i];
        numCounted += 2;
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
    
    if (session.currentFrame.camera){
        /*
         NSLog(@"%@", session.currentFrame.camera);
         
         matrix_float4x4 translation = matrix_identity_float4x4;
         translation.columns[3].z = -0.2;
         
         matrix_float4x4 transform = matrix_multiply(session.currentFrame.camera.transform, translation);
         
         NSLog(@"hi");
         //   Add a new anchor to the session
         ARAnchor *anchor = [[ARAnchor alloc] initWithTransform:transform];
         [session addAnchor:anchor];
         */
        
    }
    
    anchors->addAnchor(ofVec2f(touch.x,touch.y));
    
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
