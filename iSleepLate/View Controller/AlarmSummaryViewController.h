//
//  AlarmSummaryViewController.h
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SmartAlarm;

@interface AlarmSummaryViewController : UIViewController

@property (weak, nonatomic) SmartAlarm *alarm;

@end
