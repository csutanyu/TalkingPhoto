//
//  KTThumbsViewController.m
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTThumbsViewController.h"
#import "KTThumbsView.h"
#import "KTThumbView.h"
#import "KTPhotoScrollViewController.h"
#import "AppDelegate.h"
#import "Photo2AudioFileEntity.h"

@interface KTThumbsViewController (Private)
@end


@implementation KTThumbsViewController
@synthesize dataSource = dataSource_;
@synthesize speakController = speakController_;

- (id)init
{
  if (self = [super init]) {
    speakController_ = [SpeakHereController shareInstance];
    lastRecordIndex_ = -1;
  }
  
  return  self;
}

- (void)dealloc {
   [scrollView_ release], scrollView_ = nil;
  speakController_.delegate = nil, speakController_ = nil;
  
   [super dealloc];
}

- (void)loadView {
   // Make sure to set wantsFullScreenLayout or the photo
   // will not display behind the status bar.
   [self setWantsFullScreenLayout:YES];

   KTThumbsView *scrollView = [[KTThumbsView alloc] initWithFrame:CGRectZero];
   [scrollView setDataSource:self];
   [scrollView setController:self];
   [scrollView setScrollsToTop:YES];
   [scrollView setScrollEnabled:YES];
   [scrollView setAlwaysBounceVertical:YES];
   [scrollView setBackgroundColor:[UIColor whiteColor]];
   
   if ([dataSource_ respondsToSelector:@selector(thumbsHaveBorder)]) {
      [scrollView setThumbsHaveBorder:[dataSource_ thumbsHaveBorder]];
   }
   
   if ([dataSource_ respondsToSelector:@selector(thumbSize)]) {
      [scrollView setThumbSize:[dataSource_ thumbSize]];
   }
   
   if ([dataSource_ respondsToSelector:@selector(thumbsPerRow)]) {
      [scrollView setThumbsPerRow:[dataSource_ thumbsPerRow]];
   }
   
   
   // Set main view to the scroll view.
   [self setView:scrollView];
   
   // Retain a reference to the scroll view.
   scrollView_ = scrollView;
   [scrollView_ retain];
   
   // Release the local scroll view reference.
   [scrollView release];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated {
  // The first time the view appears, store away the current translucency so we can reset on pop.
  UINavigationBar *navbar = [[self navigationController] navigationBar];
  if (!viewDidAppearOnce_) {
    viewDidAppearOnce_ = YES;
    navbarWasTranslucent_ = [navbar isTranslucent];
  }
  // Then ensure translucency to match the look of Apple's Photos app.
  [navbar setTranslucent:YES];
  
  self.speakController.delegate = self;
  
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  // Restore old translucency when we pop this controller.
  UINavigationBar *navbar = [[self navigationController] navigationBar];
  [navbar setTranslucent:navbarWasTranslucent_];
  
  self.speakController.delegate = nil;
  
  [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)willLoadThumbs {
   // Do nothing by default.
}

- (void)didLoadThumbs {
   // Do nothing by default.
}

- (void)reloadThumbs {
   [self willLoadThumbs];
   [scrollView_ reloadData];
   [self didLoadThumbs];
}

- (void)setDataSource:(id <KTPhotoBrowserDataSource>)newDataSource {
   dataSource_ = newDataSource;
   [self reloadThumbs];
}

- (void)didSelectThumbAtIndex:(NSUInteger)index {
   KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc] 
                                                        initWithDataSource:dataSource_ 
                                                  andStartWithPhotoAtIndex:index];
  
   [[self navigationController] pushViewController:newController animated:YES];
   [newController release];
}

- (void)record4ThumbAtIndex:(NSUInteger)index
{
  [self.speakController recordOrStopRecord];
  lastRecordIndex_ = index;
}

- (void)play4ThumbAtIndex:(NSUInteger)index
{
  NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *descript = [NSEntityDescription entityForName:@"Photo2AudioFileEntity" inManagedObjectContext:context];
  [fetchRequest setEntity:descript];
  [fetchRequest setResultType:NSManagedObjectResultType];
  NSURL * assetURL = [self.dataSource urlOfImageAtIndex:index];
  NSLog(@"Play: %@", assetURL);
  NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K like %@", @"photo_file_name", [assetURL absoluteString]];
  [fetchRequest setPredicate:pred];
  NSError *error = nil;
  NSArray *resultArr = [context executeFetchRequest:fetchRequest error:&error];
  if (error != nil) {
    NSLog(@"executeFetchRequest failed with error: %@", error);
    return;
  }
  if ([resultArr count] == 0) {
    // TODO
    return;
  }
  Photo2AudioFileEntity *lEntry = [resultArr objectAtIndex:0];
  self.speakController.audioRecordFilePath = lEntry.audio_file_name;
  NSLog(@"play:%@", lEntry.audio_file_name);
  [self.speakController play];
}


#pragma mark -
#pragma mark KTThumbsViewDataSource

- (NSInteger)thumbsViewNumberOfThumbs:(KTThumbsView *)thumbsView
{
   NSInteger count = [dataSource_ numberOfPhotos];
   return count;
}

- (KTThumbView *)thumbsView:(KTThumbsView *)thumbsView thumbForIndex:(NSInteger)index
{
   KTThumbView *thumbView = [thumbsView dequeueReusableThumbView];
   if (!thumbView) {
      thumbView = [[[KTThumbView alloc] initWithFrame:CGRectZero] autorelease];
      [thumbView setController:self];
   }

   // Set thumbnail image.
   if ([dataSource_ respondsToSelector:@selector(thumbImageAtIndex:thumbView:)] == NO) {
      // Set thumbnail image synchronously.
      UIImage *thumbImage = [dataSource_ thumbImageAtIndex:index];
      [thumbView setThumbImage:thumbImage];
   } else {
      // Set thumbnail image asynchronously.
      [dataSource_ thumbImageAtIndex:index thumbView:thumbView];
   }
   
   return thumbView;
}

// added by tanyu. 2012.06.07
# pragma mark - SpeakHereControllerDelegate
- (void)recordStarted:(SpeakHereController *)speaker
{
  // TODO
}

- (void)recordStoped:(SpeakHereController *)speaker
{
  NSManagedObjectContext *context = [(AppDelegate *)[UIApplication sharedApplication].delegate managedObjectContext];
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *descript = [NSEntityDescription entityForName:@"Photo2AudioFileEntity" inManagedObjectContext:context];
  [fetchRequest setEntity:descript];
  [fetchRequest setResultType:NSManagedObjectResultType];
  NSURL * assetURL = [self.dataSource urlOfImageAtIndex:lastRecordIndex_];
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
  lEntry.audio_file_name = speaker.audioRecordFilePath;
  NSLog(@"SaveRecord:%@", lEntry.audio_file_name);
  [fetchRequest release];
  error = nil;
  [context save:&error];
  if (error != nil) {
    NSLog(@"NSManagedObjectContext save failed with error: %@", error);
  }
}

- (void)playbackQueueStopped:(SpeakHereController *)speaker
{
  
}

- (void)playbackQueueResumed:(SpeakHereController *)speaker
{
  
}

@end
