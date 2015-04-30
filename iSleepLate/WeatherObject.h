//
//  WeatherDetails.h
//  iSleepLate
//
//  Created by Laura Humphries on 4/7/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WeatherObject : NSObject

@property (nonatomic) NSTimeInterval expectedTravelTime;
@property (strong, nonatomic) NSDictionary *iconNames;

@property (strong, nonatomic) NSString *cityName;

// current weather data
@property (strong, nonatomic) NSString *currentWeatherDescription; // this is the description of the weather
@property (strong, nonatomic) NSString *shortWeatherDescription;
@property (strong, nonatomic) NSString *currentWeatherIconName;
@property (nonatomic) NSNumber *currentTemperature;

// forecast weather data
@property (strong, nonatomic) NSMutableArray *forecastTimes;
@property (strong, nonatomic) NSMutableArray *forecastIcons;
@property (strong, nonatomic) NSMutableArray *forecastTemperatures;

// public methods
- (void) updateWeather;
- (void) updateWeatherForecast;
- (NSString *)getWeatherDescription;
- (UIImage *)imageWithIconName: (NSString *)iconName;

@end
