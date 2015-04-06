//
//  AlertViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/3/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmLabel;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton1;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton2;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingViewMarginTop;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation AlertViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.alarm scheduleLocalNotification];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:@"AppDidRecieveLocalNotifcation"
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetDisplay];
    
    [self updateTime];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.loadingViewMarginTop.constant = CGRectGetHeight(self.view.frame) - 64;
    [self.loadingView setNeedsUpdateConstraints];
}

#pragma mark - Private Methods

- (void)resetDisplay
{
    self.silenceButton.hidden = YES;
    self.snoozeButton1.hidden = YES;
    self.snoozeButton2.hidden = YES;
    self.loadingView.hidden = YES;
    
    [self updateAlarmLabel];
}

- (void)updateAlarmLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    NSString *alarmTime = [formatter stringFromDate:self.alarm.localNotification.fireDate];
    self.alarmLabel.text = [NSString stringWithFormat:@"Alarm %@", alarmTime];
}

- (void)updateTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    NSString *time = [formatter stringFromDate:[NSDate date]];
    time = [time stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];      // remove AM/PM
    time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.timeLabel.text = time;
}

- (void)showSnoozeButtons
{
    NSDate *leaveTime = [self.alarm.dateOfArrival dateByAddingTimeInterval:-(self.alarm.expectedTravelTime)];
    NSUInteger prepTime = [leaveTime timeIntervalSinceDate:[NSDate date]];
    NSUInteger minutes = prepTime / 60;
    NSLog(@"You have %u minutes to get ready.", minutes);
    
    self.snoozeButton1.hidden = minutes < 5;
    self.snoozeButton2.hidden = minutes < 10;
}

- (void)resetLoadingView
{
    [UIView animateWithDuration:0.25
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:0.0
                        options:0
                     animations:^{
                         self.loadingView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.snoozeButton1.hidden = NO;
                         self.snoozeButton2.hidden = NO;
                         self.loadingView.hidden = YES;
                         self.loadingViewMarginTop.constant = CGRectGetHeight(self.view.frame) - 64;
                         self.loadingView.alpha = 1.0;
                     }];
}

#pragma mark - NSNotifcationCenter

- (void)handleNotification:(NSNotification *)note
{
    self.silenceButton.hidden = NO;
    [self showSnoozeButtons];
}

#pragma mark - Touch Events

- (void)showLoading
{
    self.snoozeButton1.hidden = YES;
    self.snoozeButton2.hidden = YES;
    self.loadingView.hidden = NO;
    
    self.loadingViewMarginTop.constant = 0.0;
    [self.loadingView setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:1.25
                          delay:0.0
         usingSpringWithDamping:1.0
          initialSpringVelocity:2.0
                        options:0
                     animations:^{
                         [self.loadingView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self resetLoadingView];
                     }];
}

- (IBAction)userPressedSilenceButton:(id)sender
{
    [self showLoading];
}

- (IBAction)userLiftedSilenceButton:(id)sender
{
    CALayer *currentLayerInAnimation = [self.loadingView.layer presentationLayer];
    CGFloat marginTop = CGRectGetMinY(currentLayerInAnimation.frame) - 64; // 64 = status bar + navBar
    self.loadingViewMarginTop.constant = marginTop;
    
    [self.loadingView.layer removeAllAnimations];
}

- (IBAction)snooze:(id)sender
{
    if (sender == self.snoozeButton1) {
        [self.alarm snoozeForNSTimeInterval:300];
    } else if (sender == self.snoozeButton2) {
        [self.alarm snoozeForNSTimeInterval:600];
    }
    
    [self resetDisplay];
}

@end
