//
//  WeatherDetailsViewController.m
//  iSleepLate
//
//  Created by Laura Humphries on 4/24/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "WeatherDetailsViewController.h"
#import "AppDelegate.h"

@implementation WeatherDetailsViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    [self displayWeatherData];
    
    self.navigationController.navigationBarHidden = NO;
}

- (NSString *) hourStringFromComponents: (NSDateComponents *) components{
    NSString *str;
    // AM
    if(components.hour == 0) {
        str = [NSString stringWithFormat:@"12AM"];
    }
    else if (components.hour < 12) {
        str = [NSString stringWithFormat:@"%dAM", components.hour];
    }
    else if (components.hour == 12) {
        str = [NSString stringWithFormat:@"12PM"];
    }
    else { // components.hour >= 12
        str = [NSString stringWithFormat:@"%dPM", components.hour - 12];
    }
    return str;
}

- (void) displayWeatherData {
    
    // get the app delegate's weather object
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    WeatherObject *weather = appDelegate.weather;
    
    // set the current weather description labels
    [self.currentDescriptionLabel setText:weather.shortWeatherDescription];
    [self.currentTemperatureLabel setText:[NSString stringWithFormat:@"%@°", weather.currentTemperature]];
    [self.currentTemperatureLabel2 setText:[weather.currentTemperature stringValue]];
    [self.currentWeatherIcon setIconWithIconName:weather.currentWeatherIconName];
    
    // city name
    [self.cityLabel setText:weather.cityName];
    
    // set the weather forecast description labels (weather updated before seque)
    
    
    // time labels
    NSDate *date = [NSDate date];
    NSDateComponents *components =  [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"EEEE"];
    [self.currentDayLabel setText:[dateFormat stringFromDate:date]];
    

    if (weather.forecastTimes.count == 4) {
        dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    
        date = [dateFormat dateFromString:weather.forecastTimes[0]];
        components =  [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:date];
        [self.hourLabel1 setText:[self hourStringFromComponents: components]];
        
        date = [dateFormat dateFromString:weather.forecastTimes[1]];
        components =  [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:date];
        [self.hourLabel2 setText:[self hourStringFromComponents: components]];
        
        date = [dateFormat dateFromString:weather.forecastTimes[2]];
        components =  [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:date];
        [self.hourLabel3 setText:[self hourStringFromComponents: components]];
        
        date = [dateFormat dateFromString:weather.forecastTimes[3]];
        components =  [[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:date];
        [self.hourLabel4 setText:[self hourStringFromComponents: components]];
        
        dateFormat = nil;
    }
    
    // icons
    if(weather.forecastIcons.count == 4) {
        [self.weatherIcon1 setIconWithIconName:weather.forecastIcons[0]];
        [self.weatherIcon2 setIconWithIconName:weather.forecastIcons[1]];
        [self.weatherIcon3 setIconWithIconName:weather.forecastIcons[2]];
        [self.weatherIcon4 setIconWithIconName:weather.forecastIcons[3]];
    }
    // temperature labels
    if(weather.forecastTemperatures.count == 4) {
        [self.temperatureLabel1 setText:[weather.forecastTemperatures[0] stringValue]];
        [self.temperatureLabel2 setText:[weather.forecastTemperatures[1] stringValue]];
        [self.temperatureLabel3 setText:[weather.forecastTemperatures[2] stringValue]];
        [self.temperatureLabel4 setText:[weather.forecastTemperatures[3] stringValue]];
    }
    
    // high and low???
    
    appDelegate = nil;
    weather = nil;
    date = nil;
    components = nil;
    dateFormat = nil;
}

@end
