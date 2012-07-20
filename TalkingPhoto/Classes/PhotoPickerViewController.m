//
//  PhotoPickerViewController.m
//  PhotoSpeaker
//
//  Created by tanyu on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoPickerViewController.h"
#import "PhotoManager.h"
#import <ImageIO/ImageIO.h>
#import "AppDelegate.h"
#import "ThumbnailViewController.h"

#define RowHeight   80

@interface PhotoPickerViewController ()

@end

@implementation PhotoPickerViewController
@synthesize tableView = _tableView;
@synthesize photoStream = _photoStream;
@synthesize album = _album;
@synthesize event = _event;
@synthesize faces = _faces;

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
	// Do any additional setup after loading the view.
//  _album = [[NSMutableArray alloc] init];
//  _photoStream = [[NSMutableArray alloc] init];
//  _event = [[NSMutableArray alloc] init];
//  _faces = [[NSMutableArray alloc] init];
//  NSComparator comp = ^(id obj1, id obj2)
//  {
//    NSComparisonResult res = NSOrderedSame;
//    
//    NSDictionary * leftDict = (NSDictionary *)[[[(ALAsset *)obj1 representationForUTI:@"public.jpg"] metadata] objectForKey:(NSString *)kCGImagePropertyExifDictionary];
//    NSDictionary *rightDict =(NSDictionary *)[[[(ALAsset *)obj2 representationForUTI:@"public.jpg"] metadata] objectForKey:(NSString *)kCGImagePropertyExifDictionary];
//    NSString * leftStr = [leftDict objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
//    NSString * rightStr = [rightDict objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal]; 
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *leftComp = [[[NSDateComponents alloc] init] autorelease];
//    [leftComp setYear:[leftStr componentsSeparatedByCharactersInSet:[NSCharacterSet]]];
//    return res;
//  };
  
  self.title = @"Library";
  
  _album = [[PhotoManager shareInstance].album copy];
  _photoStream = [[PhotoManager shareInstance].photoStream copy];
  _event = [[PhotoManager shareInstance].event copy];
  _faces = [[PhotoManager shareInstance].faces copy];
  
  UIBarButtonItem *ubbi = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)] autorelease];
  self.navigationItem.leftBarButtonItem = ubbi;
  self.navigationController.navigationBar.translucent = YES;
  self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
  
  [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
  _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460) style:UITableViewStylePlain];
  [self.view addSubview:_tableView];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
//  UIView * tmpView = [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
//  tmpView.backgroundColor = [UIColor redColor];
//  [_tableView addSubview:tmpView];
  
  _rowsArray = [[NSMutableArray alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
  [_rowsArray release];
  _rowsArray = nil;
  self.tableView = nil;
  self.photoStream = nil;
  self.album = nil;
  self.event = nil;
  self.faces = nil;

  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  return [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return RowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSInteger tag = [tableView cellForRowAtIndexPath:indexPath].tag;
  
  ThumbnailViewController *tvc = [[ThumbnailViewController alloc] initWithLibraryType:(TLibraryType)tag];
  [self.navigationController pushViewController:tvc animated:YES];
  [tvc release];
  
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  [_rowsArray removeAllObjects];
  
  NSInteger rowCount = 0;
  if ([self.album count] != 0)
  {
    ++rowCount;
    [_rowsArray addObject:self.album];
  }
  if ([self.photoStream count] != 0)
  {
    ++rowCount;
    [_rowsArray addObject:self.photoStream];
  }
  if ([self.event count] != 0)
  {
    ++rowCount;
    [_rowsArray addObject:self.event];
  }
  if ([self.faces count] != 0)
  {
    ++rowCount;
    [_rowsArray addObject:self.faces];
  }
  
  return rowCount;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifierOfCell = @"IdentifierOfCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierOfCell];
  if (nil == cell)
  {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierOfCell];
    NSArray *photoArray = [_rowsArray objectAtIndex:indexPath.row];
    NSString *descriptionStr = nil;
    if (photoArray == self.album)
    {
      descriptionStr = [NSString stringWithFormat:@"Camera Roll(%d)", [photoArray count]];
      cell.tag = kLibraryTypeAlbum;
    } else if (photoArray == self.photoStream)
    {
      descriptionStr = [NSString stringWithFormat:@"Photo Stream(%d)",[photoArray count]];
      cell.tag = kLibraryTypePhotoStream;
    } else if (photoArray == self.event)
    {
      descriptionStr = [NSString stringWithFormat:@"Event(%d)",[photoArray count]];
      cell.tag = kLibraryTypeEvent;
    } else if (photoArray == self.faces)
    {
      descriptionStr = [NSString stringWithFormat:@"Faces(%d)",[photoArray count]];
      cell.tag = kLibraryTypeFaces;
    } else {
      assert(!"Should never run 2 here");
    }
    ALAsset *firstAsset = [photoArray objectAtIndex:0];
    CGImageRef thumbnail = [firstAsset thumbnail];
    cell.imageView.image = [UIImage imageWithCGImage:thumbnail];
    cell.textLabel.text = descriptionStr;
  }
  
  return cell;
}

- (void)back
{
  [self.navigationController popViewControllerAnimated:NO];
//  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
