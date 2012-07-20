//
//  ThumbnailViewController.m
//  TalkingPhoto
//
//  Created by tanyu on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ThumbnailViewController.h"
#import "PhotoDataSource.h"

@interface ThumbnailViewController ()

@end

@implementation ThumbnailViewController
@synthesize data = _dataSource;

- (TLibraryType)libraryType { return _libraryType; }

- (void)setLibraryType:(TLibraryType)libraryType
{
  _libraryType = libraryType;
  self.data.libraryType = libraryType;
}

- (id)initWithLibraryType:(TLibraryType)aType
{
  if (self = [super init]) {
    self.libraryType = aType;
    if (nil == self.dataSource) {
      _dataSource = [[PhotoDataSource alloc] init];
    }
    self.data.libraryType = self.libraryType;
    [self setDataSource: self.data];
  }
  
  return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
  self.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
