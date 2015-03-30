//
//  RangeSlider.h
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RangeSliderDelegate <NSObject>


@end

@interface RangeSlider : UIControl

@property (strong, nonatomic) UIColor *trackColor;
@property (strong, nonatomic) UIColor *highlightColor;
@property (strong, nonatomic) UIColor *knobColor;

@property (nonatomic) CGFloat maximumValue;
@property (nonatomic) CGFloat minimumValue;
@property (nonatomic) CGFloat upperValue;
@property (nonatomic) CGFloat lowerValue;
@property (nonatomic) CGFloat minRange;

- (CGFloat)positionForValue:(CGFloat)value;

@end
