//
//  PhotoDataSource.h
//  TalkingPhoto
//
//  Created by tanyu on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"
#import "PhotoManager.h"
@interface PhotoDataSource : NSObject <KTPhotoBrowserDataSource>

@property (nonatomic, readwrite, assign) TLibraryType libraryType;

@end
