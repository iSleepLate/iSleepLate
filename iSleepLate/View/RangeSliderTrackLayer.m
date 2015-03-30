//
//  RangeSliderTrackLayer.m
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "RangeSliderTrackLayer.h"
#import <QuartzCore/QuartzCore.h>
#import "RangeSlider.h"

@implementation RangeSliderTrackLayer

- (void)drawInContext:(CGContextRef)ctx
{
    self.backgroundColor = self.slider.trackColor.CGColor;
    self.cornerRadius = self.bounds.size.height / 2.0;
    
    // fill the highlighed range
    CGContextSetFillColorWithColor(ctx, self.slider.highlightColor.CGColor);
    CGFloat lower = [self.slider positionForValue:self.slider.lowerValue];
    CGFloat upper = [self.slider positionForValue:self.slider.upperValue];
    CGContextFillRect(ctx, CGRectMake(lower, 0, upper - lower, self.bounds.size.height));
}

@end
