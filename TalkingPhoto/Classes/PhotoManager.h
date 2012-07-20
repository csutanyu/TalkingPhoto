//
//  PhotoManager.h
//  PhotoSpeaker
//
//  Created by tanyu on 4/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoInfoPicker.h"

enum _LibraryType {
      kLibraryTypePhotoStream     = 0,
      kLibraryTypeAlbum           = 1,
      kLibraryTypeEvent           = 2,
      kLibraryTypeFaces           = 3
  };

typedef NSInteger TLibraryType;

#define kPhotoLibraryChangedNotification  @"PhotoLibraryChangedNotification"

@interface PhotoManager : NSObject <PhotoInfoPickerProtocal>
{
  NSMutableArray *_photoStream;
  NSMutableArray *_album;
  NSMutableArray *_event;
  NSMutableArray *_faces;
  dispatch_queue_t _dispatch_queue;
@private
  PhotoInfoPicker *infoPickerPhotoStream;
  PhotoInfoPicker *infoPickerAlbum;
  PhotoInfoPicker *infoPickerEvent;
  PhotoInfoPicker *infoPickerFaces;
}

@property (nonatomic, retain) NSMutableArray * photoStream;
@property (nonatomic, retain) NSMutableArray * album;
@property (nonatomic, retain) NSMutableArray * event;
@property (nonatomic, retain) NSMutableArray * faces;
@property (nonatomic, readonly) dispatch_queue_t  dispatch_queue;

+ (PhotoManager *)shareInstance;

- (void)GetInfo;

@end
