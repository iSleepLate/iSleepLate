//
//  AlertViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/3/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AlertViewController.h"
#import "WakeUpViewController.h"
#import "AppDelegate.h"

@import AVFoundation;
@import AudioToolbox;

@interface AlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *alarmLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton1;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton2;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingViewMarginTop;

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL vibrateIsON;
@property (nonatomic) NSUInteger numberOfVibrations;

@end

@implementation AlertViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.alarm scheduleLocalNotification];
//        [self.alarm presentLocalNotification];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotification:)
                                                     name:@"AppDidRecieveLocalNotifcation"
                                                   object:nil];
        NSString *filePath = [[NSBundle mainBundle] resourcePath];
        NSURL *acutualFilePath= [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",filePath,@"Loud-alarm-clock-sound.wav"]];
        
        NSError *error;
        
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:acutualFilePath error:&error];
        _audioPlayer.numberOfLoops = 3; // 11 * 3 = 33 seconds
        
        self.numberOfVibrations = 0;
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
    self.loadingLabel.hidden = YES;
    
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
                         [self showSnoozeButtons];
                         self.loadingView.hidden = YES;
                         self.loadingLabel.hidden = YES;
                         self.timeLabel.hidden = NO;
                         self.alarmLabel.hidden = NO;
                         self.loadingViewMarginTop.constant = CGRectGetHeight(self.view.frame) - 64;
                         self.loadingView.alpha = 1.0;
                     }];
}

- (void)startVibrate
{
    if (!self.vibrateIsON || self.numberOfVibrations++ >= 33) {
        return;
    }
    
    [self performSelector:@selector(vibrate) withObject:self afterDelay:0];
    [self performSelector:@selector(vibrate) withObject:self afterDelay:0.5];
    
    [self performSelector:@selector(startVibrate) withObject:self afterDelay:2];
}

- (void)vibrate
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

#pragma mark - NSNotifcationCenter

- (void)handleNotification:(NSNotification *)note
{
    [self.audioPlayer play];
    self.vibrateIsON = YES;
    [self startVibrate];
    
    self.silenceButton.hidden = NO;
    [self showSnoozeButtons];
}

#pragma mark - Touch Events

- (void)showLoading
{
    self.snoozeButton1.hidden = YES;
    self.snoozeButton2.hidden = YES;
    self.loadingView.hidden = NO;
    self.timeLabel.hidden = YES;
    self.alarmLabel.hidden = YES;
    self.loadingLabel.hidden = NO;
    
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
                         if (finished) {
                             [self loadWakeUpView];
                         }
                         else {
                             [self resetLoadingView];
                         }
                     }];
}

- (void) loadWakeUpView {
    // turn off the alarm
    [self.audioPlayer stop];
    self.vibrateIsON = NO;

    // push to the wake up view
    [self performSegueWithIdentifier:@"ToWakeUpView" sender:self];
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


// MAKE SURE SET SECONDS TO ZERO
- (IBAction)snooze:(id)sender
{
    [self.audioPlayer stop];
    self.vibrateIsON = NO;
    
    if (sender == self.snoozeButton1) {
        [self.alarm snoozeForNSTimeInterval:300];
    } else if (sender == self.snoozeButton2) {
        [self.alarm snoozeForNSTimeInterval:600];
    }
    
    [self resetDisplay];
}

@end
