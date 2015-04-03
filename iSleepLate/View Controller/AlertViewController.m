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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *growingViewMarginTop;

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
//    self.silenceButton.hidden = YES;
    self.snoozeButton1.hidden = YES;
    self.snoozeButton2.hidden = YES;
    self.loadingView.hidden = YES;
    self.growingViewMarginTop.constant = CGRectGetHeight(self.view.frame);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.alarm presentLocalNotification];
}

#pragma mark - Private Methods

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
                         self.loadingView.hidden = YES;
                         self.growingViewMarginTop.constant = CGRectGetHeight(self.view.frame);
                         self.loadingView.alpha = 1.0;
                     }];
}

#pragma mark - NSNotifcationCenter

- (void)handleNotification:(NSNotification *)note
{
    self.silenceButton.hidden = NO;
}

#pragma mark - Touch Events

- (void)showLoading
{
    self.loadingView.hidden = NO;
    
    self.growingViewMarginTop.constant = 0.0;
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
    self.growingViewMarginTop.constant = marginTop;
    
    [self.loadingView.layer removeAllAnimations];
}

@end
