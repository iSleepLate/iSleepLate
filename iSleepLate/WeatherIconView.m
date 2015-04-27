//
//  WeatherIconView.m
//  iSleepLate
//
//  Created by Laura Humphries on 4/25/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "WeatherIconView.h"
#import "AppDelegate.h"

@implementation WeatherIconView


//- (id) initWithCoder:(NSCoder *)aDecoder {
//    self = [super initWithCoder:aDecoder];
//    if(self) {
//        [self setIconWithIconName:@"11d"];
//    }
//    return self;
//}

- (void) setIconWithIconName: (NSString *) iconName {
    // no reason to have an NSDictionary for all icons for EVERY WeatherIconView, so have one NSDictionary for all icons in WeatherObj (one per app)
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    WeatherObject* weather = appDelegate.weather;
    
    UIImage *icon = [weather imageWithIconName: iconName];
    self.backgroundColor = [[UIColor alloc] initWithPatternImage:icon];
    
    appDelegate = nil;
    weather = nil;
}

@end
