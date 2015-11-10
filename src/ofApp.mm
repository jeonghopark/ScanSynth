// http://entropedia.co.uk/generative_music/#b64K9EqAQA%3D

//int scale[24] = {-24,-12,-5,0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,31,36};
int scale[24] = {-48,-36,-28,-24,-16,-10,0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,28,36,48};


#include "ofApp.h"
#include <AVFoundation/AVFoundation.h>


//--------------------------------------------------------------
void ofApp::setup(){
    
    //    [[AVAudioSession sharedInstance] setDelegate:self];
    //    NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
    //    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    
    ofSetFrameRate(60);
    ofEnableAlphaBlending();
    
    ofBackground(0);
    
    
    synthSetting();
    
    //    ofxAccelerometer.setup();               //accesses accelerometer data
    //    ofxiPhoneAlerts.addListener(this);      //allows elerts to appear while app is running
    //	ofRegisterTouchEvents(this);            //method that passes touch events
    
    
    plotHeight = 128;
    bufferSize = 512;
    
    cameraWidth = 360;
    cameraHeight = 480;
    quarterCameraHeight = 480 * 0.25;
    
    
    if (TARGET_IPHONE_SIMULATOR) {
        debugMovie.load("debug_movie.mov");
        debugMovie.setVolume(0.0);
        debugMovie.play();
        //        bufferPixels.allocate(cameraWidth, cameraHeight * 0.25, OF_PIXELS_RGB);
    } else {
        grabber.setDeviceID( 0 );
        grabber.setDesiredFrameRate(30);
        grabber.setup(cameraWidth, cameraHeight, OF_PIXELS_BGRA);
        //        bufferPixels.allocate(cameraWidth, cameraHeight * 0.25, OF_PIXELS_RGB);
    }
    
    
    cameraTex.allocate(cameraWidth, quarterCameraHeight, GL_RGB);
    pix = new unsigned char[ (int)(cameraWidth * quarterCameraHeight * 3.0) ];
    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        bIPhone = false;
        screenW = ofGetWidth();
        screenH = ofGetWidth() * 4.0 / 3.0;
    } else {
        bIPhone = true;
        screenW = ofGetWidth();
        screenH = ofGetHeight();
    }
    
    
    videoRatio =  screenW / cameraWidth;
    
    coreSizeRatio = screenW / 5120.0;
    scoreSizeRatio = screenW / 914.0;

    
    //    videoInput = [[AVCaptureDeviceInput alloc] init];
    
    
    
    pixelColor.resize(cameraWidth);
    
    
    noteLineNum = NOTE_NUM;
    notePixelColor.resize(noteLineNum);
    linecolors.resize(noteLineNum);
    lineOnOffs.resize(noteLineNum);
    sumColor.resize(noteLineNum);
    
    for (int i=0; i<noteLineNum; i++) {
        lineOnOffs[i].bOnOff = false;
        sumColor[i] = 0;
    }
    
    synthMain.setOutputGen( synth1 * 0.8f );
    
    
    float _scoreUpY = quarterCameraHeight * videoRatio * 2;
    for (int i=0; i<noteLineNum; i++) {
        CircleMoving _lc;
        _lc.movingFactor = 3;
        _lc.movVertical = _scoreUpY;
        float _left2ndEnd = ofGetHeight()/2 - noteLineNum/2*40 + i*10;
        _lc.position = _left2ndEnd;
        circleMovings.push_back(_lc);
    }
    
    circleMovigSpeed = 7;
    
    ofSoundStreamSetup(2, 0, this, 44100, 256, 4);
    
    
}




//--------------------------------------------------------------
void ofApp::update(){
    
    if (TARGET_IPHONE_SIMULATOR) {
        debugMovie.update();
        if (debugMovie.isFrameNew()) {
            unsigned char * src = debugMovie.getPixels().getData();
            //            ofPixels & pixels = debugMovie.getPixels();
            //            if (pixels.size()>0) {
            //                for(int i = 0; i < pixels.size(); i++){
            //                    bufferPixels[i] = pixels[i];
            //                }
            //            }
            calculatePixel(src);
        }
        
    } else {
        grabber.update();
        if (grabber.isFrameNew()) {
            unsigned char * src = grabber.getPixels().getData();
            //            ofPixels & pixels = grabber.getPixels();
            //            if (pixels.size()>0) {
            //                for(int i = 0; i < pixels.size(); i++){
            //                    bufferPixels[i] = pixels[i];
            //                }
            //            }
            calculatePixel(src);
            
        }
        
    }
    
}




//--------------------------------------------------------------
void ofApp::calculatePixel(unsigned char * src){
    
    cameraTex.loadData(src, cameraWidth, quarterCameraHeight, GL_RGB);
    
    //    for (int i=0; i<cameraHeight; i++){
    //        for (int j=cameraWidth*1/4; j<cameraWidth*3; j++){
    //            int _index = i * cameraWidth*3 + j;
    //            pix[_index ] = src[_index];
    //        }
    //    }
    
    
    
    for (int i=0; i<pixelColor.size(); i+=1){
        int _index = i * 3 + quarterCameraHeight * cameraWidth * 3;
        ofColor _temp;
        _temp.r = src[_index];
        _temp.g = src[_index+1];
        _temp.b = src[_index+2];
        pixelColor[i] = _temp;


    }
    
    
    
    for (int i=0; i<noteLineNum; i+=1){
        int _index = cameraWidth * i * 3 / noteLineNum  + quarterCameraHeight * cameraWidth * 3;
        ofColor _temp;
        _temp.r = src[_index];
        _temp.g = src[_index+1];
        _temp.b = src[_index+2];
        notePixelColor[i] = _temp;
        
//        LineColor _lineColor;
//        _lineColor.fRed = src[_index];
//        _lineColor.fGreen = src[_index+1];
//        _lineColor.fBlue = src[_index+2];
        linecolors[i] = _temp;

    }
    
    
    
    //    int _leftLineRatio = (int)cameraHeight / noteLineNum;
    //    for (int i=0; i<cameraHeight; i+=_leftLineRatio) {
    //        int _index = cameraWidth*3 * i + cameraWidth*3/4;
    //        ofColor _temp;
    //        _temp.r = pix[_index];
    //        _temp.g = pix[_index+1];
    //        _temp.b = pix[_index+2];
    //        notePixelColor.push_back(_temp);
    //
    //        LineColor _lineColor;
    //        _lineColor.fRed = pix[_index];
    //        _lineColor.fGreen = pix[_index+1];
    //        _lineColor.fBlue = pix[_index+2];
    //        linecolors.push_back(_lineColor);
    //
    //    }
    
    
    
    
    //
    ////    if (pixelColor.size()>cameraHeight) {
    ////        pixelColor.erase( pixelColor.begin() );
    ////    }
    //
    //
    //    if (notePixelColor.size()>20) {
    //        notePixelColor.clear();
    //        linecolors.clear();
    //    }
    //
    //

    
    
    for (int i=0; i<noteLineNum; i++){
        
        sumColor[i] = notePixelColor[i].r + notePixelColor[i].g + notePixelColor[i].b;

//        if ( sumColor[i] < (150 * 3) && !lineOnOffs[i].bOnOff ) {
//            lineOnOffs[i].index = i;
////            lineOnOffs[i].bOnOff = true;
//        }

        if ( sumColor[i] > 450 && !lineOnOffs[i].bOnOff ) {
            lineOnOffs[i].index = i;
            lineOnOffs[i].bOnOff = true;
            synth1.setParameter("trigger1", 1);
            synth1.setParameter("carrierPitch1", scale[i] + 60);
        }
        
        
//        if (linecolors[i].bNoteTrigger) {
//            synth1.setParameter("trigger1", 1);
//            synth1.setParameter("carrierPitch1", scale[i]+20);
//            linecolors[i].bNoteTrigger = false;
//            circleMovings[i].movVertical = ofGetWidth()/2;
//            circleMovings[i].movingFactor = circleMovigSpeed;
//        }
        

        
        if (lineOnOffs[i].bOnOff) {
            circleMovings[i].movVertical = circleMovings[i].movVertical + circleMovings[i].movingFactor;
            
            if (circleMovings[i].movVertical > ofGetHeight()) {

                float _scoreUpY = quarterCameraHeight * videoRatio * 2;

                circleMovings[i].movVertical = _scoreUpY;
                circleMovings[i].movingFactor = 3;
                lineOnOffs[i].bOnOff = false;
                

            }
        }
        
    }
    
    
}


//--------------------------------------------------------------
void ofApp::onOffTest(LineOnOff & _lineOnOff){
    
//    if (_lineOnOff.bOnOff) {
//        linecolors[_lineOnOff.index].bNoteTrigger = true;
//        circleMovings[_lineOnOff.index].bMovingTrigger = true;
//        linecolors[_lineOnOff.index].index = _lineOnOff.index;
//    } else {
//        linecolors[_lineOnOff.index].bNoteTrigger = false;
//        linecolors[_lineOnOff.index].bMovingTrigger = false;
//        circleMovings[_lineOnOff.index].index = _lineOnOff.index;
//    }
    
}


//--------------------------------------------------------------
void ofApp::draw() {
    
    
    ofPushMatrix();
    cameraTex.draw( 0, 0, cameraWidth * videoRatio, quarterCameraHeight * videoRatio );

    
    
    drawScoreBase();
    
    drawBasicLine();
    
    
    
    ofPushMatrix();
    ofPushStyle();
    
    float _scoreSizeRatio = scoreSizeRatio;
    
    for (int i=0; i<noteLineNum; i++) {
        float _downSizeRatio = _scoreSizeRatio;
        float _downX = screenW * 0.5 - (pixelColor.size() - 1) * _downSizeRatio * 0.5 + i * (pixelColor.size() - 1) * _downSizeRatio / noteLineNum;
        ofPushStyle();
//        ofSetColor( notePixelColor[i] );
        ofDrawCircle(_downX, circleMovings[i].movVertical, 3);
        ofPopStyle();
    }
    
    ofPopStyle();
    ofPopMatrix();
    
    
    ofPopMatrix();
    
    
    //    ofPushMatrix();
    //    ofPushStyle();
    //    ofSetColor(ofColor::fromHsb(0, 0, 255, 255));
    //    ofDrawBitmapString( "Fr : " + ofToString(ofGetFrameRate(), 1), 10, ofGetHeight()-15 );
    //    ofPopStyle();
    //    ofPopMatrix();
    
    
    
    //    ofPushMatrix();
    //    ofPushStyle();
    //    ofSetColor(0, 255, 0, 200);
    //    ofLine(0, ofGetHeight()/2, ofGetWidth(), ofGetHeight()/2);
    //    ofLine(0, ofGetHeight()/2-10, ofGetWidth(), ofGetHeight()/2-10);
    //    ofLine(0, ofGetHeight()/2+10, ofGetWidth(), ofGetHeight()/2+10);
    //    ofPopStyle();
    //    ofPopMatrix();
    
    //    grabber.draw(0, 0, cameraWidth, cameraHeight);
    
    //    debugMovie.draw(0, 0, 480, 360);
    
    
}




//--------------------------------------------------------------
void ofApp::drawBasicLine(){

    float _coreSizeRatio = coreSizeRatio;
    float _scoreSizeRatio = scoreSizeRatio;
    float _corePointY = quarterCameraHeight * videoRatio * 1.5;
    float _scoreUpY = quarterCameraHeight * videoRatio * 2;
    
    ofPushMatrix();
    ofPushStyle();
    
    for (int i=0; i<pixelColor.size(); i++) {
        ofSetColor(pixelColor[i]);
        ofPoint _upPoint = ofPoint( i * videoRatio, quarterCameraHeight * videoRatio );
        
        float _sizeRatio = _coreSizeRatio;
        float _x = screenW * 0.5 - (pixelColor.size() - 1) * _sizeRatio * 0.5 + i * _sizeRatio;
        float _y = _corePointY;
        ofPoint _downPoint = ofPoint( _x, _y );
        ofDrawLine( _upPoint, _downPoint );
    }
    
    ofPopStyle();
    ofPopMatrix();
    
    
    
    ofPushMatrix();
    ofPushStyle();
    
    for (int i=0; i<noteLineNum; i++) {
        
        ofSetLineWidth(2);
        ofSetColor(notePixelColor[i]);
        
        float _upSizeRatio = _coreSizeRatio;
        float _upX = screenW * 0.5 - (pixelColor.size() - 1) * _upSizeRatio * 0.5 + i * (pixelColor.size() - 1) * _upSizeRatio / noteLineNum;
        float _upY = _corePointY;
        ofPoint _upPoint = ofPoint(_upX, _upY);
        
        float _downSizeRatio = _scoreSizeRatio;
        float _downX = screenW * 0.5 - (pixelColor.size() - 1) * _downSizeRatio * 0.5 + i * (pixelColor.size() - 1) * _downSizeRatio / noteLineNum;
        float _downY = _scoreUpY;
        ofPoint _downPoint = ofPoint(_downX, _downY);
        
        ofDrawLine(_upPoint, _downPoint);
        
        ofPoint _upScorePoint = ofPoint(_downX, _downY);
        ofPoint _downScorePoint = ofPoint(_downX, screenH);
        ofDrawLine(_upScorePoint, _downScorePoint);
        
        
    }
    
    ofPopStyle();
    ofPopMatrix();
    

    
}



//--------------------------------------------------------------
void ofApp::drawScoreBase(){

    
    ofPushStyle();
    ofSetColor(255);
    
    float _scoreUpY = quarterCameraHeight * videoRatio * 2;

    float _baseScorebarLength = screenW * 0.25;
    float _sX = screenW * 0.5 - _baseScorebarLength;
    float _eX = screenW * 0.5 + _baseScorebarLength;
    
    for(int i=0; i<noteLineNum; i++) {
       
        float _y = _scoreUpY + i * (screenH - _scoreUpY) / noteLineNum;
        ofPoint _sPos = ofPoint( _sX, _y);
        ofPoint _ePos = ofPoint( _eX, _y);
        
        ofDrawLine( _sPos, _ePos );
        
    }
    
    ofPopStyle();
    
    
}





//--------------------------------------------------------------
void ofApp::exit(){
    
    grabber.close();
    std::exit(0);
    
}



//--------------------------------------------------------------
void ofApp::audioRequested(float *output, int buffersize, int nChannels){
    
    synthMain.fillBufferOfFloats(output, bufferSize, nChannels);
    
}


//--------------------------------------------------------------
void ofApp::audioReceived(float * output, int bufferSize, int nChannels){
    
}



//--------------------------------------------------------------
void ofApp::touchDown(ofTouchEventArgs & touch){
    
}


//--------------------------------------------------------------
void ofApp::touchMoved(ofTouchEventArgs & touch){
    
    if (touch.id==0) {
        touchMovY = touch.y;
    }
    
}


//--------------------------------------------------------------
void ofApp::touchUp(ofTouchEventArgs & touch){
    
}


//--------------------------------------------------------------
void ofApp::touchDoubleTap(ofTouchEventArgs & touch){
    
    //    if (touch.id==0) {
    //        doubleTouchCount++;
    //        if (doubleTouchCount%2==0) {
    //            bFrontCam = !bFrontCam;
    //        }
    //    }
    //
    //    if (bFrontCam==0) {
    //        grabber.close();
    //        grabber.setDeviceID(0);
    //        grabber.setup(cameraWidth, cameraHeight,  OF_PIXELS_BGRA);
    //        grabber.update();
    //    }
    //    if (bFrontCam==1) {
    //        grabber.close();
    //        grabber.setDeviceID(1);
    //        grabber.setup(cameraWidth, cameraHeight,  OF_PIXELS_BGRA);
    //        grabber.update();
    //    }
    
    
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



//--------------------------------------------------------------
void ofApp::synthSetting(){
    
    
    ControlParameter carrierPitch1 = synth1.addParameter("carrierPitch1");
    float amountMod1 = 4;
    ControlGenerator rCarrierFreq1 = ControlMidiToFreq().input(carrierPitch1);
    ControlGenerator rModFreq1 = rCarrierFreq1 * 0.489;
    Generator modulationTone1 = SineWave().freq( rModFreq1 ) * rModFreq1 * amountMod1;
    Generator tone1 = SineWave().freq(rCarrierFreq1 + modulationTone1);
    ControlGenerator envelopTrigger1 = synth1.addParameter("trigger1");
    Generator env1 = ADSR().attack(0.001).decay(0.2).sustain(0).release(0).trigger(envelopTrigger1).legato(false);
    synth1.setOutputGen( tone1 * env1 * 0.75 );

    
}