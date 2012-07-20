//
//  CommonUtinity.m
//  TalkingPhoto
//
//  Created by tanyu on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonUtility.h"

@implementation CommonUtility
+ (NSString *)documentPath
{
  NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  
  return doc;
}

+ (NSString *)ensureCreateAudioDictonary
{
  BOOL bRet = YES;
  
  NSString *audioStr = [NSString stringWithFormat:@"%@/AudioLibrary", [CommonUtility documentPath]];
  if (NO == [[NSFileManager defaultManager] fileExistsAtPath:audioStr])
  {
    NSError *erro = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:audioStr withIntermediateDirectories:YES attributes:nil error:&erro];
    if (nil != erro) {
      bRet = NO;
      NSLog(@"create audio dictionary failed with ERRO: %@", erro);
    }
  } 
  
  return bRet ? audioStr : nil;
}

+ (NSString *)uniqueFileName
{
  NSDateFormatter *nsdf2=[[[NSDateFormatter alloc] init]autorelease];
  [nsdf2 setDateStyle:NSDateFormatterShortStyle];
  [nsdf2 setDateFormat:@"YYYYMMDDHHmmssSSSS"]; 
  
  return [[self ensureCreateAudioDictonary] stringByAppendingFormat:@"/%@", 
          [nsdf2 stringFromDate:[NSDate date]]];
}

+ (NSError *)deleteFileWithPath:(NSString *)filePath
{
  // delete old audio file
  NSError * error = nil;
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager removeItemAtPath:filePath error:&error];
  if (error != nil) {
    NSLog(@"Delete old audio file: %@  with error: %@", filePath, error);
  }

  return error;
}

@end
