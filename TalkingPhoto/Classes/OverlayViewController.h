//
//  OverlayViewController.h
//  TalkingPhoto
//
//  Created by tanyu on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCamPreviewView.h"
#import "AVCamCaptureManager.h"
#import "SpeakHereController.h"
#import "AQLevelMeter.h"


@class AVCaptureVideoPreviewLayer;
@protocol OverlayViewControllerDelegate;

@interface OverlayViewController : UIViewController <UIAccelerometerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCamPreviewViewDelegate, AVCamCaptureManagerDelegate, SpeakHereControllerDelegate>
{
  id <OverlayViewControllerDelegate> delegate;
  
  //accelerometer
	UIAccelerometer *sharedAccelerometer;
	float globalAccelerometerValue;
	float movementValueWhileTakingPicture;
	float globalMovementThreshold;

@private
	// AVCam stuff
	AVCamCaptureManager *_captureManager;
	AVCamPreviewView *_videoPreviewView;
	AVCaptureVideoPreviewLayer *_captureVideoPreviewLayer;
	
	CALayer *_focusBox;
  CALayer *_exposeBox;
  
  UIImage *_capturedImage;
  NSURL   *_urlOfCapturedImage;
  NSString *_recordFile;

  
  BOOL _oldNavgationBarHidden;
  BOOL _statusBarHidden;
}

#pragma mark - Outlet
@property (retain, nonatomic) IBOutlet UIButton *sutterButton;
@property (retain, nonatomic) IBOutlet UIButton *toggleCameraButton;

@property (retain, nonatomic) IBOutlet UIImageView *stillImageView;
@property (retain, nonatomic) IBOutlet UIView *recordTab;
@property (retain, nonatomic) IBOutlet UIView *useOrRetake;
@property (retain, nonatomic) IBOutlet UIView *secondView;
@property (retain, nonatomic) IBOutlet UIButton *recordButton;
@property (retain, nonatomic) IBOutlet UIView *firstView;
@property (retain, nonatomic) IBOutlet AQLevelMeter *lvlMeter_in;
@property(nonatomic,assign) id <OverlayViewControllerDelegate> delegate;

#pragma mark - Action
- (IBAction)libraryButtonPressed:(id)sender;
- (IBAction)cameraToggle:(id)sender;
- (IBAction)dismissPhotoPicker:(id)sender;

- (IBAction)shutterAction:(id)sender;
- (IBAction)back2Camera:(id)sender;
- (IBAction)playRecordFile:(id)sender;
- (IBAction)recordButtonTouched:(id)sender;
- (IBAction)usePhotoAction:(id)sender;
- (IBAction)reTakeAction:(id)sender;
- (IBAction)recordOKButton:(id)sender;

//AVCam
@property (nonatomic,retain) AVCamCaptureManager *captureManager;
@property (nonatomic,retain) IBOutlet AVCamPreviewView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

#pragma mark AVCam
-(void)initAVCam;
#pragma mark taking images
-(void)takePictureNotingAccelerometerValue;
-(void)takePictureWithAVCam;


#pragma mark accelerometer
-(void)initAccelerometerWithoutStarting;
-(void)startAccelerometer;
-(void)stopAccelerometer;
#pragma mark accelerometer compute movement
-(float)computeMovementWithX:(float)accelX andY:(float)accelY andZ:(float)accelZ;

@end

@protocol OverlayViewControllerDelegate <NSObject>
-(void)didFinishWithImage:(UIImage *)image movement:(float)movementVal threshold:(float)thresholdVal;
-(void)handleImageSavingError:(NSError *)error;

@end
