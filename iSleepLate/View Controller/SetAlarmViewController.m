//
//  SetAlarmViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/31/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SetAlarmViewController.h"

@interface SetAlarmViewController ()

@property (weak, nonatomic) IBOutlet UIButton *setAlarmButton;

@end

@implementation SetAlarmViewController

- (void)viewDidLoad
{
    self.setAlarmButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.alarm printAlarmInfo];
    
    if (![self.alarm verifyFireDate]) {
        [self showAlertForPastFireDate];
    } else {
        self.setAlarmButton.enabled = YES;
    }
}

- (void)showAlertForPastFireDate
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Could Not Schedule Alarm!"
                                                                             message:@"There is not enough time to get you to your destination at the desired time."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                               [self.navigationController popToRootViewControllerAnimated:YES];
                                                   }];
    [alertController addAction:action];
//    [self presentViewController:alertController animated:YES completion:nil];
    [self performSegueWithIdentifier:@"ToAlertView" sender:self];
}

@end
