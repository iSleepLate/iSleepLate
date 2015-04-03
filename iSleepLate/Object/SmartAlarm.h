//
//  SmartAlarm.h
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MapKit;

@interface SmartAlarm : NSObject

// user defined variables
@property (strong, nonatomic) NSDate *dateOfArrival;
@property (strong, nonatomic) MKMapItem *destination;
@property (nonatomic) NSRange preparationTime;

// calculated variables
@property (nonatomic) NSTimeInterval expectedTravelTime;
@property (nonatomic) MKMapItem *currentLocation;

- (void)printAlarmInfo;
- (void)scheduleLocalNotification;
- (void)presentLocalNotification;
- (void)cancelScheduledLocalNotification;

@end
