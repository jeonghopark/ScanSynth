#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"

#include "ofxTonic.h"

#define NOTE_NUM 24

using namespace Tonic;

struct InputMovie {
    ofColor color;
    int index;
};


struct LineColor {
    float fRed;
    float fGreen;
    float fBlue;
    
    float movingFactor;
    float movVertical;
    bool bMovingTrigger;
    bool bNoteTrigger;
    int index;
};

struct CircleMoving{
    float movingFactor;
    float movVertical;
    bool bMovingTrigger;
    int index;
    float position;
};


struct LineOnOff{
    int index;
    bool bOnOff;
};

class ofApp : public ofxiOSApp{
	
    ofxTonicSynth synth1;
    ofxTonicSynth synth2;
    ofxTonicSynth synth3;
    ofxTonicSynth synth4;
    ofxTonicSynth synthMain;

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
    
    void audioRequested (float * output, int bufferSize, int nChannels);
    void audioReceived(float * input, int bufferSize, int nChannels);
    
    vector<LineOnOff> lineOnOffs;
    vector<float> sumColor;
    ofEvent<LineOnOff> onOff[NOTE_NUM];
    void onOffTest(LineOnOff & _lineOnOffs);
    
    int cameraDevice;
    int doubleTouchCount;
    bool bFrontCam;
    ofVideoGrabber grabber;
    ofTexture cameraTex;
    unsigned char * pix;
    ofPixels bufferPixels;
        
    vector<ofColor> pixelColor;
    vector<ofColor> notePixelColor;
    vector<float> colorNumber;
    vector<float> randomYPos;
    int noteLineNum;
    
    vector<ofColor> linecolors;
    vector<CircleMoving> circleMovings;
    vector<InputMovie> inputVideo;
    
    int cameraWidth, cameraHeight;
    float screenW, screenH;
    float touchMovY;

    int plotHeight, bufferSize;

    
    int circleMovigSpeed;
    
    ofVideoPlayer debugMovie;
    ofImage bufferDebugMovie;
    
    void calculatePixel(unsigned char * src);
    
    bool bIPhone;
    
    int quarterCameraHeight;
    float videoRatio;
    
    float coreSizeRatio;
    float scoreSizeRatio;

    
    void drawBasicLine();
    void drawScoreBase();

    
    void synthSetting();


};



