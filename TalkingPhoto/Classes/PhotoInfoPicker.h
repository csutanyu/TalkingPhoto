//
//  PhotoInfoPicker.h
//  PhotoSpeaker
//
//  Created by tanyu on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


@protocol PhotoInfoPickerProtocal;

@interface PhotoInfoPicker : NSObject
{
  ALAssetsGroupType _assetGroupType;
  id<PhotoInfoPickerProtocal> _delegate;
  ALAssetsLibrary * _assetsLibrary;
  dispatch_queue_t _dispatcQueue;
}
@property (nonatomic, assign) id<PhotoInfoPickerProtocal> delegate;
@property (nonatomic, assign) ALAssetsGroupType assetsGroupType;
@property (nonatomic, readonly) ALAssetsLibrary * assetsLibrary;
@property (nonatomic, assign) dispatch_queue_t dispatchQueue;

- (id)initWithAssetsGroupType:(ALAssetsGroupType) aAssetsGroupType delegate:(id<PhotoInfoPickerProtocal>)aDelegate;

- (void)GetPhotoAsserts;

@end

@protocol PhotoInfoPickerProtocal <NSObject>

@required

- (void)photoInfoPicker:(PhotoInfoPicker *)infoPicker getNewAsset:(ALAsset *) aAsset;
                         
@end

