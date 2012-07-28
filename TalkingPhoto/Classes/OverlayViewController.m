//
//  OverlayViewController.m
//  TalkingPhoto
//
//  Created by tanyu on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OverlayViewController.h"
#import "AVCamPreviewView.h"
#import "AVCamCaptureManager.h"
#import "PhotoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"
#import "PhotoManager.h"
#import "Photo2AudioFileEntity.h"
#import "CommonUtility.h"

@interface OverlayViewController ()
@property (nonatomic,retain) CALayer *focusBox;
@property (nonatomic,retain) CALayer *exposeBox;
@end

@interface OverlayViewController (InternalMethods)
- (CALayer *)createLayerBoxWithColor:(UIColor *)color;
+ (CGRect)cleanApertureFromPorts:(NSArray *)ports;
+ (CGSize)sizeForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize;
+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove;
- (CGPoint)translatePoint:(CGPoint)point fromGravity:(NSString *)gravity1 toGravity:(NSString *)gravity2;
- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point;
- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point;
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
@end

@interface OverlayViewController(tanyu)
- (void)savePhoto2Library;
- (void)saveRecord;
- (void)deleteRecordFile;
- (void)releaseRecordAboutResources;
@end


@implementation OverlayViewController
@synthesize sutterButton;
@synthesize toggleCameraButton;
@synthesize stillImageView;
@synthesize recordTab;
@synthesize useOrRetake;
@synthesize secondView;
@synthesize recordButton;
@synthesize firstView;
@synthesize delegate;

//AVCam
@synthesize captureManager = _captureManager;
@synthesize videoPreviewView = _videoPreviewView;
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;

@synthesize focusBox = _focusBox;
@synthesize exposeBox = _exposeBox;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  [self.sutterButton setImage:[UIImage imageNamed:@"shutter_portrait_nor.png"] forState:UIControlStateNormal];
  [self.sutterButton setImage:[UIImage imageNamed:@"shutter_portrait_down.png"] forState:UIControlStateHighlighted];
  
  stillImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
  
  _capturedImage = nil;
  _urlOfCapturedImage = nil;
  _capturedImage = nil;
  
  self.useOrRetake.hidden = NO;
  self.recordTab.hidden = YES;
  secondView.hidden = YES;
  
  self.view.frame = CGRectMake(0, 0, 320, 480);
  self.firstView.frame = CGRectMake(0, 0, 320, 480);
  self.secondView.frame = CGRectMake(0, 0, 320, 480);
  
  [self initAVCam];
}

- (void)viewDidUnload
{
  [self setSutterButton:nil];
  [self setToggleCameraButton:nil];
  [self setStillImageView:nil];
  [self setRecordTab:nil];
  [self setUseOrRetake:nil];
  [self setSecondView:nil];
  [self setFirstView:nil];
  [self setRecordButton:nil];
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if (![self.captureManager.session isRunning]) {
    [self.captureManager.session startRunning];
  }
  
  _statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
  [UIApplication sharedApplication].statusBarHidden = YES;
  
  if ([self.captureManager cameraCount] < 2) {
    self.toggleCameraButton.hidden = YES;
  }
  _oldNavgationBarHidden = self.navigationController.navigationBarHidden;
  self.navigationController.navigationBarHidden = YES;
  
  self.captureVideoPreviewLayer.frame = CGRectMake(0, 0, 320, 427);
  [self.firstView viewWithTag:2].frame = CGRectMake(0, 427, 320, 53);


  stillImageView.frame = CGRectMake(0, 0, 320, 427);
  [self.secondView viewWithTag:2].frame = CGRectMake(0, 427, 320, 53); 
  
  [SpeakHereController shareInstance].delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  
  if (![self.captureManager.session isRunning]) {
    [self.captureManager.session startRunning];
  }

  [UIApplication sharedApplication].statusBarHidden = _statusBarHidden;
  self.navigationController.navigationBarHidden = _oldNavgationBarHidden;
  
  [SpeakHereController shareInstance].delegate = nil;
  [self releaseRecordAboutResources];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark accelerometer initialize
-(void)initAccelerometerWithoutStarting{
	sharedAccelerometer = [UIAccelerometer sharedAccelerometer];
	sharedAccelerometer.updateInterval = 1.0f/60.0f;
}

#pragma mark taking images
- (void)takePictureWithAVCam
{
  [[self captureManager] captureStillImage];
  
  UIView *flashView = [[UIView alloc] initWithFrame:[[self videoPreviewView] frame]];
  [flashView setBackgroundColor:[UIColor whiteColor]];
  [flashView setAlpha:0.f];
  [[[self view] window] addSubview:flashView];
  
  [UIView animateWithDuration:.4f
                   animations:^{
                     [flashView setAlpha:1.f];
                     [flashView setAlpha:0.f];
                   }
                   completion:^(BOOL finished){
                     [flashView removeFromSuperview];
                     [flashView release];
                   }
   ];
}


-(void)startAccelerometer{
	sharedAccelerometer.delegate = self;
}

-(void)stopAccelerometer{
	sharedAccelerometer.delegate = nil;
}

#pragma mark AVCam
-(void)initAVCam{
	NSError *error;
	AVCamCaptureManager *captureManager = [[AVCamCaptureManager alloc] init];
	if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetHigh error:&error]){
#ifdef DEBUG
		NSLog(@"captureManager retain count in initAVCam:%d",[captureManager retainCount]);
#endif
		[self setCaptureManager:captureManager];
#ifdef DEBUG
		NSLog(@"captureManager retain count in initAVCam after first assignment:%d",[[self captureManager] retainCount]);
#endif
		AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		[[captureManager session] startRunning];
		[self setCaptureVideoPreviewLayer:captureVideoPreviewLayer];
		
		UIView *view = [self videoPreviewView];
		[[self videoPreviewView] setDelegate:self];
		CALayer *viewLayer = [view layer];
		[viewLayer setMasksToBounds:YES];
		CGRect bounds = [view bounds];
		[captureVideoPreviewLayer setFrame:bounds];
		
		if ([captureVideoPreviewLayer isOrientationSupported]) {
			[captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
		}
		
		
		if ([[captureManager session] isRunning]){
			
			CALayer *focusBox = [self createLayerBoxWithColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.8f]];
			[viewLayer addSublayer:focusBox];
			[self setFocusBox:focusBox];
			
			CALayer *exposeBox = [self createLayerBoxWithColor:[UIColor colorWithRed:1.f green:1.f blue:1.f alpha:.8f]]; 
			[viewLayer addSublayer:exposeBox];
			[self setExposeBox:exposeBox];
			
			CGPoint screenCenter = CGPointMake(bounds.size.width/2.0, bounds.size.width/2.0);
			[self drawFocusBoxAtPointOfInterest:screenCenter];
			[self drawExposeBoxAtPointOfInterest:screenCenter];
			
			[captureManager setOrientation:AVCaptureVideoOrientationPortrait];
			[captureManager setDelegate:self];
			
			[viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
			[captureVideoPreviewLayer release];
		}
		else{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                          message:@"Failed to start session."
                                                         delegate:nil
                                                cancelButtonTitle:@"Okay"
                                                otherButtonTitles:nil];
			[alertView show];
			[alertView release];
			
		}
	}
	else{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Input Device Init Failed"
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
		[alertView show];
		[alertView release];  
	}
	
	[captureManager release];
#ifdef DEBUG
	NSLog(@"captureManager retain count in initAVCam after release:%d",[[self captureManager] retainCount]);
#endif
}


#pragma mark accelerometer compute movement
-(float)computeMovementWithX:(float)accelX andY:(float)accelY andZ:(float)accelZ{
	return 1000*(fabs(accelX) + fabs(accelY) + fabs(accelZ));
}

- (void)dealloc {
  [sutterButton release];
  [toggleCameraButton release];
  [stillImageView release];
  [recordTab release];
  [useOrRetake release];
  [secondView release];
  [firstView release];
  [recordButton release];
  [super dealloc];
}

#pragma mark - Action
- (IBAction)libraryButtonPressed:(id)sender {
#if 0
  [self.navigationController pushViewController:[(AppDelegate *)[UIApplication sharedApplication].delegate photoPickerviewController] animated:NO];//  [self.navigationController popViewControllerAnimated:NO];
  //  PhotoPickerViewController *ppvc = [[PhotoPickerViewController alloc] init];
  //  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ppvc];
  //  [ppvc release];
  //  [self presentModalViewController:nav animated:YES];
  //  [nav release];
#else
  // 动画弹出框
  __block NSMutableArray *options = [NSMutableArray array];
  dispatch_sync([PhotoManager shareInstance].dispatch_queue, ^(void)
                {
                  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                  
                  if ([[PhotoManager shareInstance].album count] != 0)
                  {
                    ALAsset * tmp_asset = [[PhotoManager shareInstance].album lastObject];
                    NSDictionary *tmp_dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIImage imageWithCGImage:[tmp_asset thumbnail]], @"img",
                                              [NSString stringWithFormat:@"Camera Roll (%d)", [[PhotoManager shareInstance].album count]], @"text",
                                              [NSString stringWithFormat:@"%d", kLibraryTypeAlbum], @"tag",
                                              nil];
                    [options addObject:tmp_dict];
                  }
                  
                  if ([[PhotoManager shareInstance].photoStream count] != 0)
                  {
                    ALAsset * tmp_asset = [[PhotoManager shareInstance].photoStream lastObject];
                    NSDictionary *tmp_dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIImage imageWithCGImage:[tmp_asset thumbnail]], @"img",
                                              [NSString stringWithFormat:@"Photo Stream (%d)", [[PhotoManager shareInstance].album count]], @"text",
                                              [NSString stringWithFormat:@"%d", kLibraryTypePhotoStream], @"tag",
                                              nil];
                    
                    [options addObject:tmp_dict];
                  }
                  
                  [pool drain];
                });
  
  LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"Albums" options:options];
  lplv.delegate = [(AppDelegate *)([UIApplication sharedApplication].delegate) rootViewController];
  [lplv showInView:self.navigationController.view animated:YES];
  [lplv release];
#endif
}

- (IBAction)cameraToggle:(id)sender {
  [self.captureManager cameraToggle];
}

- (IBAction)dismissPhotoPicker:(id)sender {
  [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)shutterAction:(id)sender {
  [self takePictureWithAVCam];
}

- (IBAction)back2Camera:(id)sender {
  // 去掉录音文件及数据库中的记录
  if (_recordFile && [_recordFile length] != 0) {
    [CommonUtility deleteFileWithPath:_recordFile];
  }
  if (_urlOfCapturedImage /*&& ...*/) {
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *descript = [NSEntityDescription entityForName:@"Photo2AudioFileEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:descript];
    [fetchRequest setResultType:NSManagedObjectResultType];
    NSURL * assetURL = _urlOfCapturedImage;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K like %@", @"photo_file_name", [assetURL absoluteString]];
    [fetchRequest setPredicate:pred];
    NSError *error = nil;
    NSArray *resultArr = [context executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
      NSLog(@"executeFetchRequest failed with error: %@", error);
      return;
    } else {
      Photo2AudioFileEntity *lEntry = nil;
      // delete old audio file
      for (NSInteger i = 0; i < [resultArr count]; ++i) {
        // 实际上只可能有一个记录
        lEntry = [resultArr objectAtIndex:i];          
        [CommonUtility deleteFileWithPath:lEntry.audio_file_name];
        [context deleteObject:lEntry];
      } // for
    } //     if (error != nil) {
  } //   if (_urlOfCapturedImage /*&& ...*/) {
  
  [self releaseRecordAboutResources];
  [self.captureManager.session startRunning];

  [UIView transitionWithView:self.view duration:0.0
                     options:UIViewAnimationOptionCurveLinear
                  animations:^(void){
                    secondView.hidden = YES;
                    firstView.hidden = NO;
                  } completion:^(BOOL)
   {
//     [self.captureManager.session startRunning];
   }];
}

- (IBAction)playRecordFile:(id)sender {

  [SpeakHereController shareInstance].audioRecordFilePath = _recordFile;
  [[SpeakHereController shareInstance] play];
}

- (IBAction)recordButtonTouched:(id)sender {
  [[SpeakHereController shareInstance] recordOrStopRecord];
}

- (IBAction)usePhotoAction:(id)sender {
  // 存图片到library
  [self savePhoto2Library];
  self.useOrRetake.hidden = YES;
  self.recordTab.hidden = NO;
  [secondView setNeedsDisplay];  
}

- (IBAction)reTakeAction:(id)sender {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
    [self.captureManager.session startRunning];
  });
  [self releaseRecordAboutResources];
//  [UIView transitionFromView:secondView toView:firstView duration:0.5 options:UIViewAnimationOptionCurveLinear completion:NULL];
//  [self.captureManager.session startRunning];
  [UIView transitionWithView:self.view duration:.0
                     options:UIViewAnimationOptionCurveLinear
                  animations:^(void){
                    firstView.hidden = NO;
                    secondView.hidden = YES;
                  } completion:^(BOOL)
  {
//    [self.captureManager.session startRunning];
  }];

}

- (IBAction)recordOKButton:(id)sender {
  [self releaseRecordAboutResources];
}

#pragma mark - OverlayViewController (InternalMethods)

- (CALayer *)createLayerBoxWithColor:(UIColor *)color
{
  NSDictionary *unanimatedActions = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"bounds",[NSNull null], @"frame",[NSNull null], @"position", nil];
  CALayer *box = [[CALayer alloc] init];
  [box setActions:unanimatedActions];
  [box setBorderWidth:3.f];
  [box setBorderColor:[color CGColor]];
  [box setOpacity:0.f];
  [unanimatedActions release];
  
  return [box autorelease];
}



+ (CGRect)cleanApertureFromPorts:(NSArray *)ports
{
  CGRect cleanAperture;
  for (AVCaptureInputPort *port in ports) {
    if ([port mediaType] == AVMediaTypeVideo) {
      cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
      break;
    }
  }
  return cleanAperture;
}

+ (CGSize)sizeForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
  CGFloat apertureRatio = apertureSize.height / apertureSize.width;
  CGFloat viewRatio = frameSize.width / frameSize.height;
  
  CGSize size;
  if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
    if (viewRatio > apertureRatio) {
      size.width = frameSize.width;
      size.height = apertureSize.width * (frameSize.width / apertureSize.height);
    } else {
      size.width = apertureSize.height * (frameSize.height / apertureSize.width);
      size.height = frameSize.height;
    }
  } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
    if (viewRatio > apertureRatio) {
      size.width = apertureSize.height * (frameSize.height / apertureSize.width);
      size.height = frameSize.height;
    } else {
      size.width = frameSize.width;
      size.height = apertureSize.width * (frameSize.width / apertureSize.height);
    }
  } else if ([gravity isEqualToString:AVLayerVideoGravityResize]) {
    size.width = frameSize.width;
    size.height = frameSize.height;
  }
  
  return size;
}

+ (void)addAdjustingAnimationToLayer:(CALayer *)layer removeAnimation:(BOOL)remove
{
  if (remove) {
    [layer removeAnimationForKey:@"animateOpacity"];
  }
  if ([layer animationForKey:@"animateOpacity"] == nil) {
    [layer setHidden:NO];
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacityAnimation setDuration:.3f];
    [opacityAnimation setRepeatCount:1.f];
    [opacityAnimation setAutoreverses:YES];
    [opacityAnimation setFromValue:[NSNumber numberWithFloat:1.f]];
    [opacityAnimation setToValue:[NSNumber numberWithFloat:.0f]];
    [layer addAnimation:opacityAnimation forKey:@"animateOpacity"];
  }
}

- (CGPoint)translatePoint:(CGPoint)point fromGravity:(NSString *)oldGravity toGravity:(NSString *)newGravity
{
  CGPoint newPoint;
  
  CGSize frameSize = [[self videoPreviewView] frame].size;
  
  CGSize apertureSize = [OverlayViewController cleanApertureFromPorts:[[[self captureManager] videoInput] ports]].size;
  
  CGSize oldSize = [OverlayViewController sizeForGravity:oldGravity frameSize:frameSize apertureSize:apertureSize];
  
  CGSize newSize = [OverlayViewController sizeForGravity:newGravity frameSize:frameSize apertureSize:apertureSize];
  
  if (oldSize.height < newSize.height) {
    newPoint.y = ((point.y * newSize.height) / oldSize.height) - ((newSize.height - oldSize.height) / 2.f);
  } else if (oldSize.height > newSize.height) {
    newPoint.y = ((point.y * newSize.height) / oldSize.height) + ((oldSize.height - newSize.height) / 2.f) * (newSize.height / oldSize.height);
  } else if (oldSize.height == newSize.height) {
    newPoint.y = point.y;
  }
  
  if (oldSize.width < newSize.width) {
    newPoint.x = (((point.x - ((newSize.width - oldSize.width) / 2.f)) * newSize.width) / oldSize.width);
  } else if (oldSize.width > newSize.width) {
    newPoint.x = ((point.x * newSize.width) / oldSize.width) + ((oldSize.width - newSize.width) / 2.f);
  } else if (oldSize.width == newSize.width) {
    newPoint.x = point.x;
  }
  
  return newPoint;
}

- (void)drawFocusBoxAtPointOfInterest:(CGPoint)point
{
  AVCamCaptureManager *captureManager = [self captureManager];
  if ([captureManager hasFocus]) {
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    CGSize apertureSize = [OverlayViewController cleanApertureFromPorts:[[[self captureManager] videoInput] ports]].size;
    
    CGSize oldBoxSize = [OverlayViewController sizeForGravity:[[self captureVideoPreviewLayer] videoGravity] frameSize:frameSize apertureSize:apertureSize];
    
    CGPoint focusPointOfInterest = [[[captureManager videoInput] device] focusPointOfInterest];
    CGSize newBoxSize;
//    if (focusPointOfInterest.x == .5f && focusPointOfInterest.y == .5f) {
//      newBoxSize.width = (116.f / frameSize.width) * oldBoxSize.width;
//      newBoxSize.height = (158.f / frameSize.height) * oldBoxSize.height;
//    } else {
//      newBoxSize.width = (80.f / frameSize.width) * oldBoxSize.width;
//      newBoxSize.height = (110.f / frameSize.height) * oldBoxSize.height;
//    }
    newBoxSize.width = 50.f;
    newBoxSize.height = 50.f;

    CALayer *focusBox = [self focusBox];
    [focusBox setFrame:CGRectMake(0.f, 0.f, newBoxSize.width, newBoxSize.height)];
    [focusBox setPosition:point];
    [OverlayViewController addAdjustingAnimationToLayer:focusBox removeAnimation:YES];
  }
}

- (void)drawExposeBoxAtPointOfInterest:(CGPoint)point
{
  AVCamCaptureManager *captureManager = [self captureManager];
  if ([captureManager hasExposure]) {
    CGSize frameSize = [[self videoPreviewView] frame].size;
    
    CGSize apertureSize = [OverlayViewController cleanApertureFromPorts:[[[self captureManager] videoInput] ports]].size;
    
    CGSize oldBoxSize = [OverlayViewController sizeForGravity:[[self captureVideoPreviewLayer] videoGravity] frameSize:frameSize apertureSize:apertureSize];
    
    CGPoint exposurePointOfInterest = [[[captureManager videoInput] device] exposurePointOfInterest];
    CGSize newBoxSize;
//    if (exposurePointOfInterest.x == .5f && exposurePointOfInterest.y == .5f) {
//      newBoxSize.width = (290.f / frameSize.width) * oldBoxSize.width;
//      newBoxSize.height = (395.f / frameSize.height) * oldBoxSize.height;
//    } else {
//      newBoxSize.width = (114.f / frameSize.width) * oldBoxSize.width;
//      newBoxSize.height = (154.f / frameSize.height) * oldBoxSize.height;
//    }
    newBoxSize.width = 50.f;
    newBoxSize.height = 50.f;
    
    CALayer *exposeBox = [self exposeBox];
    [exposeBox setFrame:CGRectMake(0.f, 0.f, newBoxSize.width, newBoxSize.height)];
    [exposeBox setPosition:point];
    [OverlayViewController addAdjustingAnimationToLayer:exposeBox removeAnimation:YES];
  }
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates 
{
  CGPoint pointOfInterest = CGPointMake(.5f, .5f);
  CGSize frameSize = [[self videoPreviewView] frame].size;
  
  AVCaptureVideoPreviewLayer *videoPreviewLayer = [self captureVideoPreviewLayer];
  
  if ([[self captureVideoPreviewLayer] isMirrored]) {
    viewCoordinates.x = frameSize.width - viewCoordinates.x;
  }    
  
  if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResize] ) {
    pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
  } else {
    CGRect cleanAperture;
    for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
      if ([port mediaType] == AVMediaTypeVideo) {
        cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
        CGSize apertureSize = cleanAperture.size;
        CGPoint point = viewCoordinates;
        
        CGFloat apertureRatio = apertureSize.height / apertureSize.width;
        CGFloat viewRatio = frameSize.width / frameSize.height;
        CGFloat xc = .5f;
        CGFloat yc = .5f;
        
        if ( [[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspect] ) {
          if (viewRatio > apertureRatio) {
            CGFloat y2 = frameSize.height;
            CGFloat x2 = frameSize.height * apertureRatio;
            CGFloat x1 = frameSize.width;
            CGFloat blackBar = (x1 - x2) / 2;
            if (point.x >= blackBar && point.x <= blackBar + x2) {
              xc = point.y / y2;
              yc = 1.f - ((point.x - blackBar) / x2);
            }
          } else {
            CGFloat y2 = frameSize.width / apertureRatio;
            CGFloat y1 = frameSize.height;
            CGFloat x2 = frameSize.width;
            CGFloat blackBar = (y1 - y2) / 2;
            if (point.y >= blackBar && point.y <= blackBar + y2) {
              xc = ((point.y - blackBar) / y2);
              yc = 1.f - (point.x / x2);
            }
          }
        } else if ([[videoPreviewLayer videoGravity] isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
          if (viewRatio > apertureRatio) {
            CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
            xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
            yc = (frameSize.width - point.x) / frameSize.width;
          } else {
            CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
            yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
            xc = point.y / frameSize.height;
          }
        }
        
        pointOfInterest = CGPointMake(xc, yc);
        break;
      }
    }
  }
  
  return pointOfInterest;
}

# pragma mark -  OverlayViewController(tanyu)
- (void)savePhoto2Library
{
  if (_capturedImage == nil) {
    return;
  }
  
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  [library writeImageToSavedPhotosAlbum:[_capturedImage CGImage]
                            orientation:(ALAssetOrientation)[_capturedImage imageOrientation]
                        completionBlock:^(NSURL *assetURL, NSError *error){
                          if (error) {
                            NSLog(@"Save photo error: %@", error);
                          } else {
                            _urlOfCapturedImage = [assetURL copy];
                          }
                        }];
  [library release];
}

- (void)saveRecord
{
  if (_recordFile != nil) { // 保存到数据库
    NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *descript = [NSEntityDescription entityForName:@"Photo2AudioFileEntity" inManagedObjectContext:context];
    [fetchRequest setEntity:descript];
    [fetchRequest setResultType:NSManagedObjectResultType];
    NSURL * assetURL = _urlOfCapturedImage;
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K like %@", @"photo_file_name", [assetURL absoluteString]];
    [fetchRequest setPredicate:pred];
    NSError *error = nil;
    NSArray *resultArr = [context executeFetchRequest:fetchRequest error:&error];
    if (error != nil) {
      NSLog(@"executeFetchRequest failed with error: %@", error);
      return;
    }
    Photo2AudioFileEntity *lEntry = nil;
    if ([resultArr count] == 0) {
      lEntry = (Photo2AudioFileEntity *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo2AudioFileEntity" inManagedObjectContext:context] ;
      lEntry.photo_file_name = [assetURL absoluteString];
    } else {
      lEntry = (Photo2AudioFileEntity *)[resultArr objectAtIndex:0];
      
      // delete old audio file
      [CommonUtility deleteFileWithPath:lEntry.audio_file_name];
    }
    lEntry.audio_file_name = _recordFile;
    NSLog(@"SaveRecord:%@", lEntry.audio_file_name);
    [fetchRequest release];
    error = nil;
    [context save:&error];
    if (error != nil) {
      NSLog(@"NSManagedObjectContext save failed with error: %@", error);
    }
  }
  
  // release the photo and record file
//  [self releaseRecordAboutResources];
}

- (void)deleteRecordFile
{
  _recordFile != nil ? [CommonUtility deleteFileWithPath:_recordFile], _recordFile = nil : nil;
}

- (void)releaseRecordAboutResources
{
  _capturedImage != nil ? [_capturedImage release], _capturedImage = nil : _capturedImage;
  _urlOfCapturedImage != nil ? [_urlOfCapturedImage release], _urlOfCapturedImage =nil : _urlOfCapturedImage;
  _recordFile != nil ? [_recordFile release], _recordFile = nil : _recordFile;
}


# pragma mark - AVCamPreviewViewDelegate

- (void)tapToFocus:(CGPoint)point
{
  AVCamCaptureManager *captureManager = [self captureManager];
  if ([[[captureManager videoInput] device] isFocusPointOfInterestSupported]) {
    CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:point];
    [captureManager focusAtPoint:convertedFocusPoint];
    [self drawFocusBoxAtPointOfInterest:point];
  }
}

- (void)tapToExpose:(CGPoint)point
{
  AVCamCaptureManager *captureManager = [self captureManager];
  if ([[[captureManager videoInput] device] isExposurePointOfInterestSupported]) {
    CGPoint convertedExposurePoint = [self convertToPointOfInterestFromViewCoordinates:point];
    [[self captureManager] exposureAtPoint:convertedExposurePoint];
    [self drawExposeBoxAtPointOfInterest:point];
  }
}

- (void)resetFocusAndExpose
{
  CGPoint pointOfInterest = CGPointMake(.5f, .5f);
  [[self captureManager] focusAtPoint:pointOfInterest];
  [[self captureManager] exposureAtPoint:pointOfInterest];
  
  CGRect bounds = [[self videoPreviewView] bounds];
  CGPoint screenCenter = CGPointMake(bounds.size.width / 2.f, bounds.size.height / 2.f);
  
  [self drawFocusBoxAtPointOfInterest:screenCenter];
  [self drawExposeBoxAtPointOfInterest:screenCenter];
  
  [[self captureManager] setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
}

#pragma mark - AVCamCaptureManagerDelegate
-(void)getCapturedImage:(UIImage *)capturedImage
{
  stillImageView.image = capturedImage;
  
  _capturedImage = [capturedImage retain];
  self.useOrRetake.hidden = NO;
  self.recordTab.hidden = YES;
  
//  [UIView transitionFromView:firstView toView:secondView duration:0.5 options:UIViewAnimationOptionCurveLinear completion:NULL];
  [self.captureManager.session stopRunning];
  [UIView transitionWithView:self.view duration:0.0
                     options:UIViewAnimationOptionCurveLinear
                  animations:^(void){
                    firstView.hidden = YES;
                    secondView.hidden = NO;
                  } completion:^(BOOL)
   {
//     [self.captureManager.session stopRunning];
   }];
  [[self delegate] didFinishWithImage:capturedImage movement:movementValueWhileTakingPicture threshold:globalMovementThreshold];	
}

-(void)captureStillImageFailedWithError:(NSError *)error
{
	[[self delegate] handleImageSavingError:error];
}

#pragma mark - SpeakHereControllerDelegate
- (void)recordStarted:(SpeakHereController *)speaker
{
  // TODO
  [self.recordButton setTitle:@"stop" forState:UIControlStateNormal];
}

- (void)recordStoped:(SpeakHereController *)speaker
{
  _recordFile = speaker.audioRecordFilePath;
  // 存到数据库
  [self saveRecord];
  [self.recordButton setTitle:@"record" forState:UIControlStateNormal];
}

- (void)playbackQueueStopped:(SpeakHereController *)speaker
{
  // TODO
}

- (void)playbackQueueResumed:(SpeakHereController *)speaker
{
  // TODO
}

@end
