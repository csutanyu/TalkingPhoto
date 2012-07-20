//
//  Utility.h
//  UXinClient
//
//  Created by Liam on 11-7-22.
//  Copyright 2011 D-TONG-TELECOM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utility : NSObject {

}

+(Utility*)shareUtility;

- (NSString *) md5:(NSString *)str ;

@end
