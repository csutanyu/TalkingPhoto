//
//  RootViewController.m
//  TalkingPhoto
//
//  Created by tanyu on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "PhotoPickerViewController.h"
#import "OverlayViewController.h"
#import "AppDelegate.h"
#import "PhotoManager.h"
#import "ThumbnailViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize animatedImagesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  self.animatedImagesView.delegate = self;

}

- (void)viewDidUnload
{
  [self setAnimatedImagesView:nil];
  [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = YES;
  [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
  [self.animatedImagesView startAnimating];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  self.navigationController.navigationBarHidden = NO;
  [self.animatedImagesView stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
  [animatedImagesView release];
  [super dealloc];
}

#pragma mark - JSAnimatedImagesViewDelegate Methods

- (NSUInteger)animatedImagesNumberOfImages:(JSAnimatedImagesView *)animatedImagesView
{
  return 3;
}

- (UIImage *)animatedImagesView:(JSAnimatedImagesView *)animatedImagesView imageAtIndex:(NSUInteger)index
{
  return [UIImage imageNamed:[NSString stringWithFormat:@"animated_image%d.jpg", index + 1]];
}

- (IBAction)takephoto:(id)sender {
  [self.navigationController pushViewController:[(AppDelegate *)[UIApplication sharedApplication].delegate overlayViewController] animated:NO];
//  OverlayViewController *ovc = [[OverlayViewController alloc] init];
//  [self.navigationController pushViewController:ovc animated:NO];
//  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
//    [self presentModalViewController:ovc animated:YES];
//  } else {
//    [self presentViewController:ovc animated:YES completion:nil];
//  }
//  [ovc release];
}

- (IBAction)photoLibrary:(id)sender {
#if 0
  self.definesPresentationContext = YES;
  self.providesPresentationContextTransitionStyle = YES;
  self.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
  
  PhotoPickerViewController *pv = [(AppDelegate *)[UIApplication sharedApplication].delegate photoPickerviewController];
  pv.modalTransitionStyle = UIModalTransitionStylePartialCurl;
  [self presentViewController:pv animated:YES completion:nil];
  
//  [self.navigationController pushViewController:[(AppDelegate *)[UIApplication sharedApplication].delegate photoPickerviewController] animated:NO];
//  PhotoPickerViewController *ppvc = [[PhotoPickerViewController alloc] init];
//  [self.navigationController pushViewController:ppvc animated:NO];
//  [ppvc release];
//  UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ppvc];
//  [ppvc release];
//  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
//    [self presentModalViewController:nav animated:YES];
//  } else {
//    [self presentViewController:nav animated:YES completion:nil];
//  }
//  [nav release];
#else
  // 动画弹出框
  __block NSMutableArray *options = [NSMutableArray array];
  dispatch_sync([PhotoManager shareInstance].dispatch_queue, ^(void)
  {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    if ([[PhotoManager shareInstance].album count] != 0)
    {
      ALAsset * tmp_asset = [[PhotoManager shareInstance].album lastObject];
      NSDictionary *tmp_dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageWithCGImage:[tmp_asset thumbnail]], @"img",
                                [NSString stringWithFormat:@"Camera Roll (%d)", [[PhotoManager shareInstance].album count]], @"text",
                                [NSString stringWithFormat:@"%d", kLibraryTypeAlbum], @"tag",
                                nil];
      [options addObject:tmp_dict];
    }
    
    if ([[PhotoManager shareInstance].photoStream count] != 0)
    {
      ALAsset * tmp_asset = [[PhotoManager shareInstance].photoStream lastObject];
      NSDictionary *tmp_dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIImage imageWithCGImage:[tmp_asset thumbnail]], @"img",
                                [NSString stringWithFormat:@"Photo Stream (%d)", [[PhotoManager shareInstance].album count]], @"text",
                                [NSString stringWithFormat:@"%d", kLibraryTypePhotoStream], @"tag",
                                nil];
      
      [options addObject:tmp_dict];
    
    }        
    
    [pool drain];
  });
  
  LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"Albums" options:options];
  lplv.delegate = self;
  [lplv showInView:self.navigationController.view animated:YES];
  [lplv release];

#endif
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSIndexPath *)anIndex;
{
  NSInteger tag = [popListView.tableView cellForRowAtIndexPath:anIndex].tag;
  
//  UIBarButtonItem *ubbi = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)] autorelease];
//  self.navigationController.navigationBar.backItem.title = @"back"
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  ThumbnailViewController *tvc = [[ThumbnailViewController alloc] initWithLibraryType:(TLibraryType)tag];
  [self.navigationController pushViewController:tvc animated:NO];
  [tvc release];
}
- (void)leveyPopListViewDidCancel
{
  // TODO
}

@end
