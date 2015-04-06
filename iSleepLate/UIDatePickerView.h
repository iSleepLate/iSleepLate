//
//  UIDatePickerView.h
//  iSleepLateLearning
//
//  Created by Laura Humphries on 4/1/15.
//  Copyright (c) 2015 com.isleeplate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIDatePickerDelegate <UIPickerViewDelegate>

@end

@interface UIDatePickerView : UIPickerView <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, weak) id<UIDatePickerDelegate> delegate;

-(void) scrollToCurrentTime;
-(NSDate *) date;

@end
