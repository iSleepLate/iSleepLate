//
//  RangeSlider.m
//  iSleepLate
//
//  Created by David Neubauer on 3/29/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "RangeSlider.h"
#import "RangeSliderKnobLayer.h"
#import "RangeSliderTrackLayer.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const RangeSliderThumbSize = 26.0;

@interface RangeSlider ()

@property (strong, nonatomic) UIView *trackView;
@property (strong, nonatomic) UIView *leftKnob;
@property (strong, nonatomic) UIView *rightKnob;
@property (strong, nonatomic) UIView *trackHighlight;
@property (weak, nonatomic)   UIView *viewInMotion;

@property (strong, nonatomic) RangeSliderTrackLayer *trackLayer;
@property (strong, nonatomic) RangeSliderKnobLayer *leftKnobLayer;
@property (strong, nonatomic) RangeSliderKnobLayer *rightKnobLayer;

@property (nonatomic) CGFloat knobWidth;
@property (nonatomic) CGFloat useableTrackLength;
@property (nonatomic) CGPoint previousTouchPoint;

@end

@implementation RangeSlider

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.minimumValue = 0.0;
        self.maximumValue = 100.0;
        self.lowerValue = self.minimumValue;
        self.upperValue = self.maximumValue;
        
        self.backgroundColor = [UIColor clearColor];
        self.highlightColor = [UIColor colorWithRed:234/255.0 green:100/255.0 blue:90/255.0 alpha:1.0];
        self.knobColor = [UIColor whiteColor];
        self.trackColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        
        // Background layer of track
        self.trackLayer = [RangeSliderTrackLayer layer];
        self.trackLayer.slider = self;
        [self.layer addSublayer:self.trackLayer];
        
        // leftKnob
        self.leftKnobLayer = [RangeSliderKnobLayer layer];
        self.leftKnobLayer.slider = self;
        [self.layer addSublayer:self.leftKnobLayer];
        
        // rightKnob
        self.rightKnobLayer = [RangeSliderKnobLayer layer];
        self.rightKnobLayer.slider = self;
        [self.layer addSublayer:self.rightKnobLayer];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self setLayerFrames];
}

#pragma mark - Public Methods


- (CGFloat)positionForValue:(CGFloat)value
{
    CGFloat range = self.maximumValue - self.minimumValue;
    CGFloat percentOfTrack = (value - self.minimumValue) / range;
    return (self.useableTrackLength * percentOfTrack) + (self.knobWidth / 2.0);
}

#pragma mark - Private Methods

#pragma mark - Setting Up the View

- (void)setLayerFrames
{
    self.trackLayer.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, 8);
    self.trackLayer.cornerRadius = CGRectGetHeight(self.trackLayer.bounds) / 2.0;
    [self.trackLayer setNeedsDisplay];
    
    self.knobWidth = self.bounds.size.height;
    self.useableTrackLength = self.bounds.size.width - self.knobWidth;
    if (!self.minRange) {
        self.minRange = (self.knobWidth / self.useableTrackLength) * (self.maximumValue - self.minimumValue);
    }
    
    CGFloat rightKnobCenter = [self positionForValue:self.upperValue];
    CGFloat knobY = -(self.knobWidth / 2.0) + self.trackLayer.frame.size.height / 2.0;
    self.rightKnobLayer.frame = CGRectMake(rightKnobCenter - self.knobWidth / 2, knobY, self.knobWidth, self.knobWidth);
    self.rightKnobLayer.cornerRadius = self.knobWidth / 2.0;
    
    CGFloat leftKnobCenter = [self positionForValue:self.lowerValue];
    self.leftKnobLayer.frame = CGRectMake(leftKnobCenter - self.knobWidth / 2, knobY, self.knobWidth, self.knobWidth);
    self.leftKnobLayer.cornerRadius = self.knobWidth / 2.0;
    
    [self.rightKnobLayer setNeedsDisplay];
    [self.leftKnobLayer setNeedsDisplay];
}

#pragma mark - View Updates

#pragma mark - Tracking Touches

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.previousTouchPoint = [touch locationInView:self];
    
    // hit test the knob layers
    if(CGRectContainsPoint(self.leftKnobLayer.frame, self.previousTouchPoint))
    {
        self.leftKnobLayer.highlighted = YES;
        [self.leftKnobLayer setNeedsDisplay];
    }
    else if(CGRectContainsPoint(self.rightKnobLayer.frame, self.previousTouchPoint))
    {
        self.rightKnobLayer.highlighted = YES;
        [self.rightKnobLayer setNeedsDisplay];
    }
    return self.rightKnobLayer.highlighted || self.leftKnobLayer.highlighted;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    // determine by how much the user has dragged
    CGFloat delta = touchPoint.x - self.previousTouchPoint.x;
    CGFloat valueDelta = (self.maximumValue - self.minimumValue) * delta / self.useableTrackLength;
    
    self.previousTouchPoint = touchPoint;
    
    // update the values
    if (self.leftKnobLayer.highlighted)
    {
        self.lowerValue += valueDelta;
        self.lowerValue = MIN(MAX(self.lowerValue, self.minimumValue), self.upperValue - self.minRange);
    }
    if (self.rightKnobLayer.highlighted)
    {
        self.upperValue += valueDelta;
        self.upperValue = MIN(MAX(self.upperValue, self.lowerValue + self.minRange), self.maximumValue);
    }
    
    // update the UI state
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self setLayerFrames];
    
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.leftKnobLayer.highlighted = NO;
    self.rightKnobLayer.highlighted = NO;
    
    [self.leftKnobLayer setNeedsDisplay];
    [self.rightKnobLayer setNeedsDisplay];
}

@end
