// http://entropedia.co.uk/generative_music/#b64K9EqAQA%3D

//int scale[20] = {-24,-12,-5,0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,31,36};
int scale[20] = {-48,-24,-10,0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,36,48};



#include "ofApp.h"



//--------------------------------------------------------------
void ofApp::setup(){
    

//    ofSetOrientation(OF_ORIENTATION_90_RIGHT);
    ofSetFrameRate(60);
    
    ofxAccelerometer.setup();               //accesses accelerometer data
    ofxiPhoneAlerts.addListener(this);      //allows elerts to appear while app is running
	ofRegisterTouchEvents(this);            //method that passes touch events
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
	plotHeight = 128;
    bufferSize = 512;
        
//    drawBuffer.resize(bufferSize);
//    middleBuffer.resize(bufferSize);
//    audioBuffer.resize(bufferSize);
//    
//    drawBuffer2.resize(bufferSize);
//    middleBuffer2.resize(bufferSize);
//    audioBuffer2.resize(bufferSize);
//    
//    spectrogram.allocate(bufferSize*2, plotHeight, OF_IMAGE_GRAYSCALE);
//    memset(spectrogram.getPixels(), 0, (int) (spectrogram.getWidth() * spectrogram.getHeight()) );
//    spectrogramOffset = 0;
//    
//    spectrogram2.allocate(bufferSize*2, plotHeight, OF_IMAGE_GRAYSCALE);
//    memset(spectrogram2.getPixels(), 0, (int) (spectrogram2.getWidth() * spectrogram2.getHeight()) );
//    spectrogramOffset2 = 0;
    
    ofBackground(10, 255);
    
//    cameraDevice = 1;
//    grabber.setDeviceID(cameraDevice);
    
    
    cameraWidth = 480;
    cameraHeight = 360;
    
    
    if (TARGET_IPHONE_SIMULATOR) {
        debugMovie.load("debug_movie.mp4");
        debugMovie.play();
    } else {
        grabber.setDesiredFrameRate(30);
        grabber.setup(cameraWidth, cameraHeight, OF_PIXELS_BGRA);
    }
    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        bIPhone = false;
        screenW = ofGetWidth();
        screenH = ofGetWidth() * 4.0 / 3.0;
    } else {
        bIPhone = true;
        screenW = ofGetWidth();
        screenH = ofGetHeight();
    }
	
    
    tex.allocate(cameraWidth, cameraHeight, GL_RGB);
	
    
	pix = new unsigned char[ (int)( cameraWidth * cameraHeight * 3.0) ];
    
    //    videoInput = [[AVCaptureDeviceInput alloc] init];
    
    leftTwentyLineNumber = 20;

    
    pixelColor.resize(cameraHeight);
    
    
    ControlParameter carrierPitch1 = synth1.addParameter("carrierPitch1");
    float amountMod1 = 4;
    ControlGenerator rCarrierFreq1 = ControlMidiToFreq().input(carrierPitch1);
    ControlGenerator rModFreq1 = rCarrierFreq1 * 0.489;
    Generator modulationTone1 = SineWave().freq( rModFreq1 ) * rModFreq1 * amountMod1;
    Generator tone1 = SineWave().freq(rCarrierFreq1 + modulationTone1);
    ControlGenerator envelopTrigger1 = synth1.addParameter("trigger1");
    Generator env1 = ADSR().attack(0.001).decay(0.2).sustain(0).release(0).trigger(envelopTrigger1).legato(false);
    synth1.setOutputGen( tone1 * env1 * 0.75 );
    
    synthMain.setOutputGen( synth1 * 0.8f );
    
    
    
    
    for (int i=0; i<leftTwentyLineNumber; i++) {
        CircleMoving _lc;
        _lc.movingFactor = 3;
        _lc.movVertical = ofGetWidth()/2;
        float _left2ndEnd = ofGetHeight()/2 - leftTwentyLineNumber/2*40 + i*10;
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
            calculatePixel(src);
        }
    } else {
        grabber.update();
        if (grabber.isFrameNew()) {
            unsigned char * src = grabber.getPixels().getData();
            calculatePixel(src);
        }
    }
    
}




//--------------------------------------------------------------
void ofApp::calculatePixel(unsigned char * src){
    
    for (int i=0; i<cameraHeight; i++){
        for (int j=cameraWidth*3/4; j<cameraWidth*3; j++){
            int _index = i * cameraWidth*3 + j;
            pix[_index ] = src[_index];
        }
    }
    
    tex.loadData(pix, cameraWidth, cameraHeight, GL_RGBA);
    
    for (int i=0; i<cameraHeight; i++){
        int _index = cameraWidth*3 * i + cameraWidth*3/4;
        ofColor _temp;
        _temp.r = pix[_index];
        _temp.g = pix[_index+1];
        _temp.b = pix[_index+2];
        pixelColor[i] = _temp;
    }
    
    
    int _leftLineRatio = (int)cameraHeight / leftTwentyLineNumber;
    for (int i=0; i<cameraHeight; i+=_leftLineRatio) {
        int _index = cameraWidth*3 * i + cameraWidth*3/4;
        ofColor _temp;
        _temp.r = pix[_index];
        _temp.g = pix[_index+1];
        _temp.b = pix[_index+2];
        twentyPixelColor.push_back(_temp);
        
        LineColor _lineColor;
        _lineColor.fRed = pix[_index];
        _lineColor.fGreen = pix[_index+1];
        _lineColor.fBlue = pix[_index+2];
        linecolors.push_back(_lineColor);
        
    }
    
//    if (pixelColor.size()>cameraHeight) {
//        pixelColor.erase( pixelColor.begin() );
//    }
    
    
    if (twentyPixelColor.size()>20) {
        twentyPixelColor.clear();
        linecolors.clear();
    }
    
    
    for (int i=0; i<leftTwentyLineNumber; i++){
        
        float _sumColor = linecolors[i].fRed + linecolors[i].fGreen + linecolors[i].fBlue;
        
        LineOnOff _lineOnOff;
        if (_sumColor<200) {
            _lineOnOff.index = i;
            _lineOnOff.bOnOff = true;
            ofNotifyEvent(onOff[i], _lineOnOff);
            ofRemoveListener(onOff[i], this, &ofApp::onOffTest);
            
        } else {
            _lineOnOff.index = i;
            _lineOnOff.bOnOff = false;
            ofNotifyEvent(onOff[i], _lineOnOff);
            ofAddListener(onOff[i], this, &ofApp::onOffTest);
        }
        
        
        if (linecolors[i].bNoteTrigger) {
            synth1.setParameter("trigger1", 1);
            synth1.setParameter("carrierPitch1", scale[i]+80);
            linecolors[i].bNoteTrigger = false;
            circleMovings[i].movVertical = ofGetWidth()/2;
            circleMovings[i].movingFactor = circleMovigSpeed;
        }
        
        if (circleMovings[i].bMovingTrigger) {
            circleMovings[i].movVertical = circleMovings[i].movVertical - circleMovings[i].movingFactor;
            if (circleMovings[i].movVertical < 0) {
                circleMovings[i].movVertical = ofGetWidth()/2;
                circleMovings[i].movingFactor = 0;
            }
        }
        
    }

    
}


//--------------------------------------------------------------
void ofApp::onOffTest(LineOnOff & _lineOnOff){

    if (_lineOnOff.bOnOff) {
        linecolors[_lineOnOff.index].bNoteTrigger = true;
        circleMovings[_lineOnOff.index].bMovingTrigger = true;
        linecolors[_lineOnOff.index].index = _lineOnOff.index;

    } else {
        linecolors[_lineOnOff.index].bNoteTrigger = false;
        linecolors[_lineOnOff.index].bMovingTrigger = false;
        circleMovings[_lineOnOff.index].index = _lineOnOff.index;
    }
    
}


//--------------------------------------------------------------
void ofApp::draw() {
    
    
    ofPushMatrix();
    ofTranslate(0, 0);
//    ofRotateX(180);
    
    float _videoRatio = 640 / cameraHeight;
	tex.draw( 0, 0, cameraWidth * _videoRatio, cameraHeight * _videoRatio );

    ofPushMatrix();
    ofPushStyle();
    
    for (int i=0; i<cameraHeight; i++) {
        ofSetLineWidth( _videoRatio );
        ofSetColor(pixelColor[i]);
        
        float _leftEndHeight = 20;
        float _leftEnd = ofGetHeight()/2 + (i * _leftEndHeight / cameraHeight) - _leftEndHeight/2;
        
        ofPoint _rightPoint = ofPoint( ofGetWidth()*6/8, i * _videoRatio );
        ofPoint _leftPoint = ofPoint( ofGetWidth()*5/8, _leftEnd );
        ofDrawLine(_leftPoint, _rightPoint);
    }
    
    ofPopStyle();
    ofPopMatrix();

    

    
//    ofPushMatrix();
//    ofPushStyle();
//    
//    for (int i=0; i<leftTwentyLineNumber; i++) {
//        ofSetColor(twentyPixelColor[i]);
//        ofSetLineWidth(2);
//        
//        float _leftEnd = ofGetHeight()/2 - leftTwentyLineNumber/2 + i;
//        float _left2ndEnd = ofGetHeight()/2 - leftTwentyLineNumber/2*10 + i*10;
//        
//        ofPoint _leftPoint = ofPoint(ofGetWidth()*5/8, _leftEnd);
//        ofPoint _rightPoint = ofPoint(ofGetWidth()*4/8, _left2ndEnd);
//        ofLine(_leftPoint, _rightPoint);
//
//        ofPoint _left2ndPoint = ofPoint(ofGetWidth()/2, _left2ndEnd);
//        ofPoint _right2ndPoint = ofPoint(0, _left2ndEnd);
//        ofLine(_left2ndPoint, _right2ndPoint);
//    }
//    
//    ofPopStyle();
//    ofPopMatrix();
    
    
//    ofPushMatrix();
//    ofPushStyle();
//
//    for (int i=0; i<leftTwentyLineNumber; i++) {
//        float _left2ndEnd = ofGetHeight()/2 - leftTwentyLineNumber/2*10 + i*10;
//        ofCircle(circleMovings[i].movVertical, _left2ndEnd, 3);
//    }
//    
//    ofPopStyle();
//    ofPopMatrix();
    
    
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
    
//    grabber.draw(0, 0, cameraWidth / 4, cameraHeight / 4);
    
    debugMovie.draw(0, 0, 480, 360);


}




//--------------------------------------------------------------
void ofApp::exit(){
    
    grabber.close();
    
}

void ofApp::audioRequested(float *output, int Buffersize, int nChannels){
    
    synthMain.fillBufferOfFloats(output, bufferSize, nChannels);

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
 
    if (touch.id==0) {
        doubleTouchCount++;
        if (doubleTouchCount%2==0) {
            bFrontCam = !bFrontCam;
        }
    }
    
    if (bFrontCam==0) {
        grabber.close();
        grabber.setDeviceID(0);
        grabber.setup(cameraWidth, cameraHeight,  OF_PIXELS_BGRA);
        grabber.update();
    }
    if (bFrontCam==1) {
        grabber.close();
        grabber.setDeviceID(1);
        grabber.setup(cameraWidth, cameraHeight,  OF_PIXELS_BGRA);
        grabber.update();
    }

    
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
