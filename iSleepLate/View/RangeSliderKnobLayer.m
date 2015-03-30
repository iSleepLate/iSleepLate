//
//  RangeSliderKnobLayer.m
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "RangeSliderKnobLayer.h"
#import "RangeSlider.h"
#import <QuartzCore/QuartzCore.h>

@implementation RangeSliderKnobLayer

- (void)drawInContext:(CGContextRef)ctx
{
    self.backgroundColor = self.slider.knobColor.CGColor;
}

@end
