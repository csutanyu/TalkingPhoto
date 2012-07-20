//
//  PhotoPickerViewController.h
//  PhotoSpeaker
//
//  Created by tanyu on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPickerViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
  UITableView *_tableView;

  NSMutableArray *_rowsArray;
  NSMutableArray *_photoStream;
  NSMutableArray *_album;
  NSMutableArray *_event;
  NSMutableArray *_faces;
}

@property (nonatomic, retain) UITableView * tableView;
@property (nonatomic, retain) NSMutableArray * photoStream;
@property (nonatomic, retain) NSMutableArray * album;
@property (nonatomic, retain) NSMutableArray * event;
@property (nonatomic, retain) NSMutableArray * faces;

@end
