//
//  WeatherDetails.h
//  iSleepLate
//
//  Created by Laura Humphries on 4/7/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherObject : NSObject

@property (nonatomic, strong) NSString *currentWeatherDescription; // this is the description of the weather
@property (nonatomic) NSTimeInterval expectedTravelTime;

- (void) updateWeather;
- (NSString *)getWeatherDescription;

@end
