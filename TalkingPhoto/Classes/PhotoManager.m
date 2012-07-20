//
//  PhotoManager.m
//  PhotoSpeaker
//
//  Created by tanyu on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoManager.h"
#import "PhotoInfoPicker.h"

static NSString * AssetInfoPickerDispatchQueue = @"g_dispatch_queue";

static PhotoManager * g_instance = nil;

@interface PhotoManager(Private)

- (void)assetsLibraryChanged:(NSNotification *)notification;

@end

@implementation PhotoManager
@synthesize photoStream = _photoStream;
@synthesize album = _album;
@synthesize event = _event;
@synthesize faces = _faces;

- (dispatch_queue_t)dispatch_queue { return _dispatch_queue; }

+ (PhotoManager *)shareInstance
{
  if (!g_instance) {
    g_instance = [[PhotoManager alloc] init];
  }
  
  return g_instance;
}

- (void)GetInfo
{
  [infoPickerPhotoStream GetPhotoAsserts];
  [infoPickerAlbum GetPhotoAsserts];
  [infoPickerEvent GetPhotoAsserts];
  [infoPickerFaces GetPhotoAsserts];
}

- (id)init
{
  if (self = [super init]) {
    _dispatch_queue = dispatch_queue_create([AssetInfoPickerDispatchQueue UTF8String], NULL);
    _album = [[NSMutableArray alloc] init];
    _photoStream = [[NSMutableArray alloc] init];
    _event = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];

    infoPickerPhotoStream = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupPhotoStream delegate:self];
    infoPickerPhotoStream.dispatchQueue = self.dispatch_queue;
    infoPickerAlbum = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupSavedPhotos delegate:self];
    infoPickerAlbum.dispatchQueue = self.dispatch_queue;
    infoPickerEvent = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupEvent delegate:self];
    infoPickerEvent.dispatchQueue = self.dispatch_queue;
    infoPickerFaces = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupFaces delegate:self];
    infoPickerFaces.dispatchQueue = self.dispatch_queue;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryChanged:) name:@"ALAssetsLibraryChangedNotification" object:nil];
  }

  return self;
}

- (void)dealloc
{
  [infoPickerPhotoStream release];
  [infoPickerAlbum release];
  [infoPickerEvent release];
  [infoPickerFaces release];
 
  dispatch_release(_dispatch_queue);
  
  self.album = nil;
  self.photoStream = nil;
  self.event = nil;
  self.faces = nil;
  
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

#pragma mark PhotoInfoPickerProtocal
- (void)photoInfoPicker:(PhotoInfoPicker *)infoPicker getNewAsset:(ALAsset *) aAsset
{
  switch (infoPicker.assetsGroupType)
  {
    case ALAssetsGroupSavedPhotos://ALAssetsGroupAlbum:
    {
      [self.album addObject:aAsset];
    }
      break;
    case ALAssetsGroupPhotoStream:
    {
      [self.photoStream addObject:aAsset];
    }
      break;
    case ALAssetsGroupEvent:
    {
      [self.event addObject:aAsset];
    }
      break;
    case ALAssetsGroupFaces:
    {
      [self.faces addObject:aAsset];
    }
      break;
      
    default:
    {
      // do nothing
    }
      break;
  }

}

#pragma mark ALAssetsLibraryChangedNotification
- (void)assetsLibraryChanged:(NSNotification *)notification
{
  [self.photoStream removeAllObjects];
  [self.album removeAllObjects];
  [self.event removeAllObjects];
  [self.faces removeAllObjects];
  
  [infoPickerPhotoStream release];
  [infoPickerAlbum release];
  [infoPickerEvent release];
  [infoPickerFaces release];
  
  infoPickerPhotoStream = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupPhotoStream delegate:self];
  infoPickerPhotoStream.dispatchQueue = self.dispatch_queue;
  infoPickerAlbum = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupSavedPhotos delegate:self];
  infoPickerAlbum.dispatchQueue = self.dispatch_queue;
  infoPickerEvent = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupEvent delegate:self];
  infoPickerEvent.dispatchQueue = self.dispatch_queue;
  infoPickerFaces = [[PhotoInfoPicker alloc] initWithAssetsGroupType:ALAssetsGroupFaces delegate:self];
  infoPickerFaces.dispatchQueue = self.dispatch_queue;
  
  [self GetInfo];
}
@end
