//
//  PhotoDataSource.m
//  TalkingPhoto
//
//  Created by tanyu on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoDataSource.h"
#import "PhotoManager.h"
#import "UIImage+Thumbnai.h"
#import "ImageIO/ImageIO.h"
#import "KTPhotoView.h"
#import "KTThumbView.h"

@interface PhotoDataSource(PrivateMethod)

- (ALAssetRepresentation *)getRepresentationAtIndex:(NSInteger)index;

- (CGImageRef)thumbnailImageWithURL:(NSURL *)aURL size:(NSInteger)aSize;
@end

@implementation PhotoDataSource
@synthesize libraryType = _libraryType;

- (NSInteger)numberOfPhotos
{
  __block NSInteger iRet = 0;
  
  dispatch_sync([PhotoManager shareInstance].dispatch_queue, ^(void)
  {
    switch (self.libraryType) {
      case kLibraryTypeAlbum:
      {
        iRet = [[PhotoManager shareInstance].album count];
      }
        break;
      case kLibraryTypePhotoStream:
      {
        iRet = [[PhotoManager shareInstance].photoStream count];
      }
        break;
      default:
        break;
    }
  });
  
  return iRet;
}

- (ALAssetRepresentation *)getRepresentationAtIndex:(NSInteger)index
{
  NSArray * tmp;
  switch (self.libraryType) {
    case kLibraryTypePhotoStream:
    {
      tmp = [PhotoManager shareInstance].photoStream;
    }
      break;
    case kLibraryTypeAlbum:
    {
      tmp = [PhotoManager shareInstance].album;
    }
      break;
    default:
      break;
  }
  
  return [(ALAsset *)[tmp objectAtIndex:index] defaultRepresentation];
}

// …or these, for asynchronous images.
- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView
{
  ALAssetRepresentation *representation = [self getRepresentationAtIndex:index];
  
  UIImage * image = [UIImage imageWithCGImage:[representation fullScreenImage]
                                        scale:[representation scale]
                                  orientation:(UIImageOrientation)[representation orientation]];

  [photoView setImage:image];
}
- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView
{  
  NSArray * tmp;
  switch (self.libraryType) {
    case kLibraryTypePhotoStream:
    {
      tmp = [PhotoManager shareInstance].photoStream;
    }
      break;
    case kLibraryTypeAlbum:
    {
      tmp = [PhotoManager shareInstance].album;
    }
      break;
    default:
      break;
  }

  CGImageRef cgImage = [(ALAsset *)[tmp objectAtIndex:index] thumbnail];
  [thumbView setThumbImage: [UIImage imageWithCGImage:cgImage]];
}

//- (void)deleteImageAtIndex:(NSInteger)index;
//- (void)exportImageAtIndex:(NSInteger)index;

- (CGSize)thumbSize
{
  return CGSizeMake(100, 100);
}
- (NSInteger)thumbsPerRow
{
  return 4;
}
- (BOOL)thumbsHaveBorder
{
  return NO;
}
//- (UIColor *)imageBackgroundColor;

- (NSURL*)urlOfImageAtIndex:(NSInteger)index
{
  NSArray * tmp;
  switch (self.libraryType) {
    case kLibraryTypePhotoStream:
    {
      tmp = [PhotoManager shareInstance].photoStream;
    }
      break;
    case kLibraryTypeAlbum:
    {
      tmp = [PhotoManager shareInstance].album;
    }
      break;
    default:
      break;
  }

  return [[(ALAsset*)[tmp objectAtIndex:index] defaultRepresentation] url];
}
//- (void)trashPhoto{}
@end
