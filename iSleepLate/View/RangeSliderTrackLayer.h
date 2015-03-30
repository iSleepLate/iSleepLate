//
//  RangeSliderTrackLayer.h
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class RangeSlider;

@interface RangeSliderTrackLayer : CALayer

@property (weak, nonatomic) RangeSlider *slider;

@end
