//
//  UIDatePickerView.m
//  iSleepLateLearning
//
//  Created by Laura Humphries on 4/1/15.
//  Copyright (c) 2015 com.isleeplate. All rights reserved.
//

#import "UIDatePickerView.h"

@implementation UIDatePickerView

//doesn't use _ prefix to avoid name clash with superclass
@synthesize delegate;

- (void)setUp
{
    super.dataSource = self;
    super.delegate = self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)setDataSource:(__unused id<UIPickerViewDataSource>)dataSource
{
    //does nothing
}


// scrolls the picker to the current time
-(void) scrollToCurrentTime
{
    // create the calendar object
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:[NSDate date]];
    
    // convert to 24 hour
    int hourRow = (int)components.hour > 12 ? (int)components.hour % 13 : (int)components.hour - 1;
    int minuteRow = components.minute / 5;
    
    // pick row that is in middle of infinite scroll
    int modifier = (6 * ((int)INT8_MAX / 12));
    hourRow += modifier;
    minuteRow += modifier;
    
    [self selectRow: hourRow
        inComponent: 0
           animated: YES];
    [self selectRow: minuteRow
        inComponent: 1
           animated: YES];
    [self selectRow: components.hour >= 12 ? 1 : 0 // 0 is AM, 1 is PM
        inComponent: 2
           animated: YES];
    
}

// get the date from this (self) picker
-(NSDate *) date {
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // select the calendar units we want from the current date (year, month, day)
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [calendar components:units fromDate:currentDate];
    
    // now we need to get the hour (most complicated from the picker) - conversion
    int selectedHour = (int)[self selectedRowInComponent:0] + 1; // this will give us
    BOOL isAm = ([self selectedRowInComponent:2] == 0);
    if(!isAm && selectedHour < 12) {
        selectedHour += 12; // convert to 24 hour time
    }
    else if(isAm && (selectedHour == 12)) {
        selectedHour = 0;
    }
    // else leave the selectedHour alone
    
    // set the rest of the components
    components.hour = selectedHour;
    components.minute = [self selectedRowInComponent:1] * 5;
    components.second = 0;
    components.nanosecond = 0;
    
    NSDate *arrivalDate = [calendar dateFromComponents:components];
    // if the arrival date is in the past
    if([arrivalDate compare:[NSDate date]] == NSOrderedAscending) {
        arrivalDate = [arrivalDate dateByAddingTimeInterval:24 * 60 * 60]; // add 24 hours to the date
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
    NSInteger rows = ((int)INT8_MAX / 12) * 12;
    switch (component) {
        case 0:     // hour
        case 1:     // minute
            return rows;
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
            label.text = [NSString stringWithFormat:@"%d", ((int)row % 12) + 1 ];
            label.textAlignment = NSTextAlignmentRight;
            break;
        case 1:
            label.text = [NSString stringWithFormat:@"%02d", ((int)row % 12) * 5];
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
