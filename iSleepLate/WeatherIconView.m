//
//  WeatherIconView.m
//  iSleepLate
//
//  Created by Laura Humphries on 4/25/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "WeatherIconView.h"

@implementation WeatherIconView


- (id) init {
    self = [super init];
    if(self) {
        //self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Clear Sky"]];
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Clear Sky"]];
//        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}
- (void) setIconWithDescription: (NSString *) description {
//    self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage       imageNamed:@"background.png"]];
}

@end
