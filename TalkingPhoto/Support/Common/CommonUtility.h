//
//  CommonUtinity.h
//  TalkingPhoto
//
//  Created by tanyu on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtility : NSObject

+ (NSString *)documentPath;

// 如果创建 "Document/AudioDictionary"失败则反回nil
+ (NSString *)ensureCreateAudioDictonary;

+ (NSString *)uniqueFileName;

+ (NSError *)deleteFileWithPath:(NSString *)filePath;
@end
