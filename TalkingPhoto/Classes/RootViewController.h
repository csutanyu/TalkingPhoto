//
//  RootViewController.h
//  TalkingPhoto
//
//  Created by tanyu on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSAnimatedImagesView.h"
#import "LeveyPopListView.h"

@interface RootViewController : UIViewController <JSAnimatedImagesViewDelegate, LeveyPopListViewDelegate>
@property (retain, nonatomic) IBOutlet JSAnimatedImagesView *animatedImagesView;
- (IBAction)takephoto:(id)sender;

- (IBAction)photoLibrary:(id)sender;

@end
