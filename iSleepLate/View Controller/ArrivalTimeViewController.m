//
//  ArrivalTime.m
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "ArrivalTimeViewController.h"
#import "DestinationViewController.h"
#import "SWRevealViewController.h"
#import "SmartAlarm.h"
#import "AppDelegate.h"
#import "UIDatePickerView.h"

@interface ArrivalTimeViewController ()

@property (weak, nonatomic) IBOutlet UIDatePickerView *timePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideMenuButton;

@end

@implementation ArrivalTimeViewController

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        self.alarm = [appDelegate alarm];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [_timePicker scrollToCurrentTime];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController)
    {
        [self.sideMenuButton setTarget: self.revealViewController];
        [self.sideMenuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // hide UIPickerView selection lines
    if (self.timePicker.subviews.count >= 2 &&
        [self.timePicker.subviews[1] isKindOfClass:[UIView class]] &&
        [self.timePicker.subviews[2] isKindOfClass:[UIView class]]) {
        ((UIView *)self.timePicker.subviews[1]).hidden = YES;
        ((UIView *)self.timePicker.subviews[2]).hidden = YES;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.alarm.dateOfArrival = [_timePicker date];
    DestinationViewController *destinationVC = segue.destinationViewController;
    destinationVC.alarm = self.alarm;
}

@end
