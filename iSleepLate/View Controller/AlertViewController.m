//
//  AlertViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/3/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController ()

@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton1;
@property (weak, nonatomic) IBOutlet UIButton *snoozeButton2;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadingViewMarginTop;

@end

@implementation AlertViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
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
    
    self.silenceButton.hidden = YES;
    self.snoozeButton1.hidden = YES;
    self.snoozeButton2.hidden = YES;
    self.loadingView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.loadingViewMarginTop.constant = CGRectGetHeight(self.view.frame) - 64;
    [self.loadingView setNeedsUpdateConstraints];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.alarm presentLocalNotification];
}

#pragma mark - Private Methods

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

@end
