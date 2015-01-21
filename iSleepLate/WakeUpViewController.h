//
//  WakeUpViewController.h
//  iSleepLate
//
//  Created by Laura Humphries on 4/20/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCTSmartAlarmViewController.h"
#import "MCSwipeTableViewCell.h"
#import "WeatherObject.h"
#import "FBShimmeringView.h"


@interface WakeUpViewController : PCTSmartAlarmViewController <UITableViewDataSource, UITableViewDelegate, MCSwipeTableViewCellDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaveByLabel;
@property (weak, nonatomic) IBOutlet UIView *slideToUnlockView;
@property (weak, nonatomic) IBOutlet UILabel *slideToUnlockLabel;
@property (weak, nonatomic) IBOutlet FBShimmeringView *shimmeringView;
@property (weak, nonatomic) IBOutlet UIImageView *slideToHideImage;
@property (weak, nonatomic) SmartAlarm *alarm;
@property (weak, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSArray *notificationItems;
@property (strong, nonatomic) WeatherObject *weather;

@end
