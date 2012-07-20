//
//  AppDelegate.h
//  TalkingPhoto
//
//  Created by tanyu on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
#import "PhotoPickerViewController.h"
#import "OverlayViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) RootViewController * rootViewController;
@property (nonatomic, retain) PhotoPickerViewController * photoPickerviewController;
@property (nonatomic, retain) OverlayViewController * overlayViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
