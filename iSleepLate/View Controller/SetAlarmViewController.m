//
//  SetAlarmViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/31/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SetAlarmViewController.h"

@implementation SetAlarmViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.alarm printAlarmInfo];
}

#pragma mark - IBActions

- (IBAction)setAlarmButtonClicked:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"Set Alarm"]) {
        [self.alarm presentLocalNotification];
//        [self.alarm scheduleLocalNotification];
        [sender setTitle:@"Cancel" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:234/255.0 green:100/255.0 blue:90/255.0 alpha:1.0];
    } else {
        [self.alarm cancelScheduledLocalNotification];
        [sender setTitle:@"Set Alarm" forState:UIControlStateNormal];
        sender.backgroundColor = [UIColor colorWithRed:12/255.0 green:51/255.0 blue:82/255.0 alpha:0.6];
    }
}

@end
