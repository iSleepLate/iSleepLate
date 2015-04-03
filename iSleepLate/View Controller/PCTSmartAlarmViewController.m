//
//  PCTSmartAlarmViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/31/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "PCTSmartAlarmViewController.h"
#import "AppDelegate.h"

@implementation PCTSmartAlarmViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self fetchSmartAlarmFromAppDelegate];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self fetchSmartAlarmFromAppDelegate];
    }
    
    return self;
}

- (void)fetchSmartAlarmFromAppDelegate
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.alarm = [appDelegate alarm];
}

@end
