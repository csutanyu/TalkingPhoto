//
/*

    File: SpeakHereController.mm
Abstract: n/a
 Version: 2.4

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2009 Apple Inc. All Rights Reserved.


*/

#import "SpeakHereController.h"

static SpeakHereController * g_instance = nil;

@implementation SpeakHereController

@synthesize player;
@synthesize recorder;

@synthesize playbackWasInterrupted;
@synthesize audioRecordFilePath = _audioFilePath;
@synthesize delegate = _delegate;
@synthesize lvlMeter_in;

char *OSTypeToStr(char *buf, OSType t)
{
	char *p = buf;
	char str[4], *q = str;
	*(UInt32 *)str = CFSwapInt32(t);
	for (int i = 0; i < 4; ++i) {
		if (isprint(*q) && *q != '\\')
			*p++ = *q++;
		else {
			sprintf(p, "\\x%02x", *q++);
			p += 4;
		}
	}
	*p = '\0';
	return buf;
}

#pragma mark Playback routines
+ (SpeakHereController *)shareInstance
{
  if (g_instance == nil) {
    @synchronized(self)
    {
      if (g_instance == nil) {
        g_instance = [[SpeakHereController alloc] init];
      }
    }
  }
  
  return g_instance;
}

-(void)stopPlayQueue
{
	player->StopQueue();
  [lvlMeter_in setAq: nil];
}

-(void)pausePlayQueue
{
	player->PauseQueue();
	playbackWasPaused = YES;
}

- (void)stopRecord
{
  [lvlMeter_in setAq: nil];
	recorder->StopRecord();
}

- (void)prepare2Play:(NSString *)aFile
{
  // dispose the previous playback queue
  player->DisposeQueue(true);
  
	// now create a new queue for the recorded file
	player->CreateQueueForFile((CFStringRef)aFile);
}

- (void)play
{
	if (player->IsRunning())
	{
		if (playbackWasPaused) {
			OSStatus result = player->StartQueue(true);
			if (result == noErr)
      {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
        if (self.delegate) {
          [self.delegate playbackQueueResumed:self];
        }
      }
		}
		else
			[self stopPlayQueue];
	}
	else
	{		
    ////////////
    // addeby by tanyu
    player->CreateQueueForFile((CFStringRef)(self.audioRecordFilePath));
    // end
    ///////////

		OSStatus result = player->StartQueue(false);
		if (result == noErr)
    {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
      if (self.delegate) {
        [self.delegate playbackQueueResumed:self];
      }
    }
	}
}

- (void)recordOrStopRecord
{
	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[self stopRecord];
    if (self.delegate) {
      [self.delegate recordStoped:self];
    }
	}
	else // If we're not recording, start.
	{				
		// Start the recorder
    self.audioRecordFilePath =  [[CommonUtility uniqueFileName] stringByAppendingFormat:@".caf"];

		recorder->StartRecord( (CFStringRef)self.audioRecordFilePath);
    // Hook the level meter up to the Audio Queue for the recorder
		[lvlMeter_in setAq: recorder->Queue()];

    if (self.delegate) {
      [self.delegate recordStarted:self];
    }
	}	
}

#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
							UInt32	inInterruptionState)
{
	SpeakHereController *THIS = (SpeakHereController*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (THIS->recorder->IsRunning()) {
			[THIS stopRecord];
		}
		else if (THIS->player->IsRunning()) {
			//the queue will stop itself on an interruption, we just need to update the UI
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
      if (THIS.delegate) {
        [THIS.delegate playbackQueueStopped:THIS];
      }
			THIS->playbackWasInterrupted = YES;
		}
	}
	else if ((inInterruptionState == kAudioSessionEndInterruption) && THIS->playbackWasInterrupted)
	{
		// we were playing back when we were interrupted, so reset and resume now
		THIS->player->StartQueue(true);
		[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:THIS];
    if (THIS.delegate) {
      [THIS.delegate playbackQueueResumed:THIS];
    }
		THIS->playbackWasInterrupted = NO;
	}
}

void propListener(	void *                  inClientData,
					AudioSessionPropertyID	inID,
					UInt32                  inDataSize,
					const void *            inData)
{
	SpeakHereController *THIS = (SpeakHereController*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;			
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			/*CFStringRef oldRoute = (CFStringRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_OldRoute));
			if (oldRoute)	
			{
				printf("old route:\n");
				CFShow(oldRoute);
			}
			else 
				printf("ERROR GETTING OLD AUDIO ROUTE!\n");
			
			CFStringRef newRoute;
			UInt32 size; size = sizeof(CFStringRef);
			OSStatus error = AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &newRoute);
			if (error) printf("ERROR GETTING NEW AUDIO ROUTE! %d\n", error);
			else
			{
				printf("new route:\n");
				CFShow(newRoute);
			}*/

			if (reasonVal == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
			{			
				if (THIS->player->IsRunning()) {
					[THIS pausePlayQueue];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueStopped" object:THIS];
				}		
			}

			// stop the queue if we had a non-policy route change
			if (THIS->recorder->IsRunning()) {
				[THIS stopRecord];
			}
		}	
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
//		if (inDataSize == sizeof(UInt32)) {
//			UInt32 isAvailable = *(UInt32*)inData;
//			// disable recording if input is not available
//			THIS->btn_record.enabled = (isAvailable > 0) ? YES : NO;
//		}
	}
}
				
#pragma mark Initialization routines
- (id)init
{		
	// Allocate our singleton instance for the recorder & player object
  if (self = [super init]) {
   	recorder = new AQRecorder();
    player = new AQPlayer();
		
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, self);
    if (error) printf("ERROR INITIALIZING AUDIO SESSION! %ld\n", error);
    else 
    {
      UInt32 category = kAudioSessionCategory_PlayAndRecord;	
      error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
      if (error) printf("couldn't set audio category!");
      
      UInt32 default2Speaker = kAudioSessionProperty_OverrideAudioRoute;
      error = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(default2Speaker), &default2Speaker);
      if (error) printf("ERROR default2Speaker! %ld\n", error);
      
      error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, self);
      if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %ld\n", error);
      UInt32 inputAvailable = 0;
      UInt32 size = sizeof(inputAvailable);
      
      // we do not want to allow recording if input is not available
      error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
      if (error) printf("ERROR GETTING INPUT AVAILABILITY! %ld\n", error);
      
      // we also need to listen to see if input availability changes
      error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, self);
      if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %ld\n", error);
      
      error = AudioSessionSetActive(true); 
      if (error) printf("AudioSessionSetActive (true) failed");
    }
    
//    UIColor *bgColor = [[UIColor alloc] initWithRed:.39 green:.44 blue:.57 alpha:.5];
//    [bgColor release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];

    
    // disable the play button since we have no recording to play yet
    playbackWasInterrupted = NO;
    playbackWasPaused = NO; 
  }
  
  return self;
}

# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
	[lvlMeter_in setAq: nil];
}

- (void)playbackQueueResumed:(NSNotification *)note
{
	[lvlMeter_in setAq: player->Queue()];
}

#pragma mark Cleanup
- (void)dealloc
{	
	delete player;
	delete recorder;
	
	[super dealloc];
}

@end
