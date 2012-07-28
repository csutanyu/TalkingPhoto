//
//  KTThumbView.m
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import "KTThumbView.h"
#import "KTThumbsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define VOICE_BUTTON_TAG      1111

@implementation KTThumbView

@synthesize controller = controller_;

- (void)dealloc 
{
   [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
   if (self = [super initWithFrame:frame]) {
      [self addTarget:self
               action:@selector(didTouch:)
     forControlEvents:UIControlEventTouchUpInside];
      
      [self setClipsToBounds:YES];
     ////
     // added by tanyu for: 添加录音按扭。 2012.05.11
     UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
     [self addSubview:btn];
     [btn setBackgroundImage:[UIImage imageNamed:@"voice_tag.png"] forState:UIControlStateNormal];
     btn.frame = CGRectMake(0, 0, 10, 10);
     btn.tag = VOICE_BUTTON_TAG;
     
//     [btn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];

     UIButton *recordBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 30, 30)];
     [self addSubview:recordBtn];
     recordBtn.backgroundColor = [UIColor blueColor];
     [recordBtn addTarget:self action:@selector(record:) forControlEvents:UIControlEventTouchUpInside];
     [recordBtn release];

     
     UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(70, 70, 30, 30)];
     [self addSubview:playBtn];
     playBtn.backgroundColor = [UIColor redColor];
     [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
     [playBtn release];

     ////

      // If the thumbnail needs to be scaled, it should mantain its aspect
      // ratio.
    [[self imageView] setContentMode:UIViewContentModeScaleAspectFill];
   }
   return self;
}

- (void)didTouch:(id)sender 
{
   if (controller_) {
      [controller_ didSelectThumbAtIndex:[self tag]];
   }
}

- (void)setThumbImage:(UIImage *)newImage 
{
  [self setImage:newImage forState:UIControlStateNormal];
}

- (void)setHasBorder:(BOOL)hasBorder
{
   if (hasBorder) {
      self.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
      self.layer.borderWidth = 1;
   } else {
      self.layer.borderColor = nil;
   }
}

/// added by tanyu. 2012.05.11
- (void)record:(id)sender
{
  if (controller_) {
    [controller_ record4ThumbAtIndex:[self tag]];
  }
  NSLog(@"Record %p", self.controller);
}

- (void)play:(id)sender
{
  if (controller_) {
    [controller_ play4ThumbAtIndex:[self tag]];
  }
  NSLog(@"Play %p", self.controller);
}

#pragma mark - overwrite
- (void)setTag:(NSInteger)tag
{
  [super setTag:tag];
  [self viewWithTag:VOICE_BUTTON_TAG].hidden = ![self.controller hasRecordFile:tag];
}
@end
