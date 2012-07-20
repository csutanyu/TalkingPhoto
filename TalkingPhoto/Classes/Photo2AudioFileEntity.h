//
//  Photo2AudioFileEntity.h
//  TalkingPhoto
//
//  Created by tanyu on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Photo2AudioFileEntity : NSManagedObject

//@property (nonatomic, retain) NSString * photo_md5;
@property (nonatomic, retain) NSString * audio_file_name;
@property (nonatomic, retain) NSString * photo_file_name;
@end
