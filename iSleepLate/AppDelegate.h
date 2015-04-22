//
//  AppDelegate.h
//  iSleepLate
//
//  Created by David Neubauer on 2/9/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "WeatherObject.h"

@import MapKit;

@class SmartAlarm;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) WeatherObject *weather;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (SmartAlarm *)alarm;


@end

