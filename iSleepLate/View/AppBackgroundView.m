//
//  AppBackgroundView.m
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AppBackgroundView.h"

@import CoreGraphics;   // CGContextDrawRadialGradient

@implementation AppBackgroundView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Create Gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    UIColor *blue = [UIColor colorWithRed:47/255.0 green:137/255.0 blue:190/255.0 alpha:1.0];
    UIColor *darkerBlue = [UIColor colorWithRed:9/255.0 green:67/255.0 blue:101/255.0 alpha:1.0];
    NSArray *colors = @[(__bridge id)blue.CGColor, (__bridge id)darkerBlue.CGColor];
    CGFloat locations[] = {0.0, 0.8};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    // Start
    CGPoint start = CGPointMake(CGRectGetWidth(rect) - 50, CGRectGetMidY(rect));
    CGFloat startRadius = 1.0;
    
    // End
    CGPoint end = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));;
    CGFloat endRadius = CGRectGetHeight(rect);

    
    CGContextDrawRadialGradient(context, gradient, start, startRadius, end, endRadius, kCGGradientDrawsBeforeStartLocation);
}

@end
