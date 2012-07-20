//
//  PhotoInfoPicker.m
//  PhotoSpeaker
//
//  Created by tanyu on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoInfoPicker.h"
#import <dispatch/dispatch.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

@interface PhotoInfoPicker(Private)


@end

@implementation PhotoInfoPicker
@synthesize delegate = _delegate;
@synthesize assetsGroupType = _assetGroupType;
@synthesize assetsLibrary = _assetsLibrary;
@synthesize dispatchQueue = _dispatcQueue;

- (id)initWithAssetsGroupType:(ALAssetsGroupType) aAssetsGroupType delegate:(id<PhotoInfoPickerProtocal>)aDelegate
{
  if (self = [super init])
  {
    _assetGroupType = aAssetsGroupType;
    _delegate = aDelegate;
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
  }
  
  return self;
}

- (void)dealloc
{
  [_assetsLibrary release];
  _assetsLibrary = nil;
  
  [super dealloc];
}
- (void)GetPhotoAsserts
{
  void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
    if(result != NULL) {      
      if ([self.delegate respondsToSelector:@selector(photoInfoPicker:getNewAsset:)])
      {
        [self.delegate photoInfoPicker:self getNewAsset:result];
      }
    }
  };
  
  void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) =  ^(ALAssetsGroup *group, BOOL *stop) {
    if(group != nil) {
      [group setAssetsFilter:[ALAssetsFilter allPhotos]];
      [group enumerateAssetsUsingBlock:assetEnumerator];
    }
  };
  
  
  dispatch_async(_dispatcQueue, ^(void){
    [self.assetsLibrary enumerateGroupsWithTypes:_assetGroupType
                                      usingBlock:assetGroupEnumerator
                                    failureBlock: ^(NSError *error) {
                                      NSLog(@"Failure");
                                    }];
  });
}
@end
