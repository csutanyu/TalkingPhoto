//
//  ThumbnailViewController.h
//  TalkingPhoto
//
//  Created by tanyu on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KTThumbsViewController.h"
#import "PhotoManager.h"
#import "PhotoDataSource.h"


@interface ThumbnailViewController : KTThumbsViewController
{
  PhotoDataSource *_dataSource;
  TLibraryType _libraryType;
}
@property (nonatomic, readwrite, assign) TLibraryType libraryType;
@property (nonatomic, retain) PhotoDataSource * data;

- (id)initWithLibraryType:(TLibraryType)aType;
@end
