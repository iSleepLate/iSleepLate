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

@interface ArrivalTimeViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UIPickerView *timePicker;
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
    [self scrollToCurrentTime];
    
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
    self.alarm.dateOfArrival = [self dateFromPicker:self.timePicker];
    DestinationViewController *destinationVC = segue.destinationViewController;
    destinationVC.alarm = self.alarm;
}

#pragma mark - Private Methods

- (void)scrollToCurrentTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute
                                               fromDate:[NSDate date]];
    // convert from 24hr to 12hr
    int hourRow = components.hour > 12 ? components.hour % 13 : components.hour - 1;
    [self.timePicker selectRow:hourRow
                   inComponent:0
                      animated:YES];
    [self.timePicker selectRow:components.minute / 5    // integer division
                   inComponent:1
                      animated:YES];
    [self.timePicker selectRow:components.hour >= 12 ? 1 : 0
                   inComponent:2
                      animated:YES];
}

- (NSDate *)dateFromPicker:(UIPickerView *)picker
{
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit units = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:units fromDate:now];
    
    // get hour
    int selectedHour = [picker selectedRowInComponent:0] + 1;
    BOOL isAM = [picker selectedRowInComponent:2] == 0;
    if (!isAM && selectedHour < 12) {
        selectedHour += 12;
    } else if (isAM && selectedHour == 12) {
        selectedHour = 0;
    }
    
    components.hour = selectedHour;
    components.minute = [picker selectedRowInComponent:1] * 5;
    components.second = 0;
    components.nanosecond = 0;
    
    NSDate *arrivalDate = [calendar dateFromComponents:components];
    if ([arrivalDate compare:[NSDate date]] == NSOrderedAscending) {
        arrivalDate = [arrivalDate dateByAddingTimeInterval:24 * 60 * 60];
    }
    
    return arrivalDate;
}


#pragma mark - Protocol Conformance

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:     // hour
        case 1:     // minute
            return 12;
        default:    // am/pm
            return 2;
    }
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 60;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 80;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
    
    // set title of label
    switch (component) {
        case 0:
            label.text = [NSString stringWithFormat:@"%d", row + 1];
            label.textAlignment = NSTextAlignmentRight;
            break;
        case 1:
            label.text = [NSString stringWithFormat:@"%02d", row * 5];
            label.textAlignment = NSTextAlignmentCenter;
            break;
        default:
            label.text = row == 0 ? @"AM" : @"PM";
            label.textAlignment = NSTextAlignmentLeft;
    }
    
    // customize appearance of label
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:50.0];
    
    return label;
}

@end
