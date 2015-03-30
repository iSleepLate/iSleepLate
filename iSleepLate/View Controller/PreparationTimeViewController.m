//
//  PreparationTimeViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "PreparationTimeViewController.h"
#import "AlarmSummaryViewController.h"
#import "RangeSlider.h"
#import "SmartAlarm.h"

@interface PreparationTimeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxLabel;
@property (weak, nonatomic) IBOutlet RangeSlider *rangeSlider;

@end

@implementation PreparationTimeViewController

- (void)viewDidLoad
{
    [self.rangeSlider addTarget:self
                         action:@selector(slideValueChanged:)
               forControlEvents:UIControlEventValueChanged];
    self.rangeSlider.minimumValue = 0.0;
    self.rangeSlider.maximumValue = 90.0;
    self.rangeSlider.minRange = 10.0;
    
    self.minLabel.text = @"Min: 0 min";
    self.maxLabel.text = @"Max: 90 min";
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSUInteger min = self.rangeSlider.lowerValue;
    NSUInteger range = self.rangeSlider.upperValue - min;
    self.alarm.preparationTime = NSMakeRange(min, range);
    AlarmSummaryViewController *alarmSummaryVC = segue.destinationViewController;
    alarmSummaryVC.alarm = self.alarm;
}

- (void)updateLabels
{
    self.minLabel.text = [NSString stringWithFormat:@"Min: %d min", (int)self.rangeSlider.lowerValue];
    self.maxLabel.text = [NSString stringWithFormat:@"Max: %d min", (int)self.rangeSlider.upperValue];
}

- (void)slideValueChanged:(id)control
{
    [self updateLabels];
}

@end
