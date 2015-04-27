//
//  PreparationTimeViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "PreparationTimeViewController.h"
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

    self.rangeSlider.minimumValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"minPrepTime"];
    self.rangeSlider.maximumValue = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxPrepTime"];
    self.rangeSlider.minRange = 10.0;
    
    if (self.alarm.preparationTime.location != 0 && self.alarm.preparationTime.length != 0) {
        self.rangeSlider.lowerValue = self.alarm.preparationTime.location;
        self.rangeSlider.upperValue = self.alarm.preparationTime.location + self.alarm.preparationTime.length;
    } else {
        self.rangeSlider.lowerValue = self.rangeSlider.minimumValue;
        self.rangeSlider.upperValue = self.rangeSlider.maximumValue;
    }
    
    self.minLabel.text = [NSString stringWithFormat:@"Min: %d min", (int)self.rangeSlider.lowerValue];
    self.maxLabel.text = [NSString stringWithFormat:@"Max: %d min", (int)self.rangeSlider.upperValue];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSInteger min = [self roundToNearestFive:self.rangeSlider.lowerValue];
    NSInteger max = [self roundToNearestFive:self.rangeSlider.upperValue];
    NSUInteger range = max - min;
    self.alarm.preparationTime = NSMakeRange(min, range);
}

- (NSInteger)roundToNearestFive:(NSInteger)number
{
    NSInteger remainder = number % 5;
    NSInteger round = (remainder > 2.5) ? 5 : 0;
    return (number - remainder) + round;
}

- (void)updateLabels
{
    NSInteger min = [self roundToNearestFive:self.rangeSlider.lowerValue];
    NSInteger max = [self roundToNearestFive:self.rangeSlider.upperValue];
    self.minLabel.text = [NSString stringWithFormat:@"Min: %d min", min];
    self.maxLabel.text = [NSString stringWithFormat:@"Max: %d min", max];
}

- (void)slideValueChanged:(id)control
{
    [self updateLabels];
}

@end
