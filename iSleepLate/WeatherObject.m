//
//  WeatherDetails.m
//  iSleepLate
//
//  Created by Laura Humphries on 4/7/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//
//  This weather details object is used to represent the data that will be shown to the user when they wake up

#import "WeatherObject.h"
#import "SmartAlarm.h"
#import "AppDelegate.h"
@import AddressBook;

#define APIKEY @"d5e9f812c964d56ef5c3b8c0edb13847"

// weather data keys
#define MAINKEY @"main"
#define TEMPKEY @"temp"
#define WEATHERKEY @"weather"
#define DESCRIPTIONKEY @"description"
// these specifically for forecast data
#define LIST @"list"
#define ICON @"icon"
#define TIME @"dt_txt"

// errors
#define CHECKCONNECTION @"Please check your connection."



@implementation WeatherObject

- (id) init {
    self = [super init];
    if(self) {
        self.currentWeatherDescription = nil;
        
        // create the NSDictionary of icon names
//        self.iconNames = [[NSDictionary alloc] initWithContentsOfFile:@"IconNames"];
        self.iconNames = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [UIImage imageNamed:@"Clear Sky Night"], @"01d",
                          [UIImage imageNamed:@"Clear Sky Night"], @"01n",
                          [UIImage imageNamed:@"Partly Cloudy"], @"02d",
                          [UIImage imageNamed:@"Partly Cloudy"], @"04d",
                          [UIImage imageNamed:@"Partly Cloudy Night"], @"02n",
                          [UIImage imageNamed:@"Partly Cloudy Night"], @"04n",
                          [UIImage imageNamed:@"Cloudy"], @"03d",
                          [UIImage imageNamed:@"Cloudy"], @"03n",
                          [UIImage imageNamed:@"Rainy"], @"09d",
                          [UIImage imageNamed:@"Rainy"], @"09n",
                          [UIImage imageNamed:@"Rainy"],@"10d",
                          [UIImage imageNamed:@"Rainy"], @"10n",
                          [UIImage imageNamed:@"Thunderstorm"], @"11d",
                          [UIImage imageNamed:@"Thunderstorm"], @"11n", 
                          [UIImage imageNamed:@"Snow"], @"13d",
                          [UIImage imageNamed:@"Snow"], @"13n",
                          [UIImage imageNamed:@"Mist"], @"50d",
                          [UIImage imageNamed:@"Mist"], @"50n", nil];
        
        // initialize weather forecast arrays
        self.forecastTimes = [[NSMutableArray alloc] init];
        self.forecastIcons = [[NSMutableArray alloc] init];
        self.forecastTemperatures = [[NSMutableArray alloc] init];
    }
    
    return self;
}

# pragma mark - public methods
- (void) updateWeather {
    
    // get reference to app delegate for the currentLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;
    
    // get the current location's country code and zip code
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error)
        {
            NSLog(@"Geocode failed with error: %@", error.localizedDescription);
            // make a request with lat and lon ? we need to get the information, but api prefers us NOT to use coordinates
//            [self makeCurrentWeatherRequestWithLat:currentLocation.coordinate.latitude Lon:currentLocation.coordinate.longitude];
            [self makeCurrentWeatherRequestWithLat:currentLocation.coordinate.latitude Lon:currentLocation.coordinate.longitude];
            
        }
        else {
            // We only want to make the request once, since multiple placemarks we make multiple in one pass - how to fix??
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *countryCode = placemark.ISOcountryCode;
            NSString *zipCode = placemark.postalCode;
            
            [self makeCurrentWeatherRequestWithZipCode:zipCode CountryCode:countryCode];
        }
    }];
    
    [self updateWeatherForecast];
}

- (void) updateWeatherForecast {
    // get reference to app delegate for the currentLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *currentLocation = appDelegate.currentLocation;
    
    NSDictionary *dictionary = appDelegate.alarm.destination.placemark.addressDictionary;
    self.cityName = dictionary[(__bridge NSString *)kABPersonAddressCityKey];
    
    [self makeWeatherForecastRequestWithLat:currentLocation.coordinate.latitude Lon:currentLocation.coordinate.longitude];
}

- (NSString *)getWeatherDescription {
    if (self.currentWeatherDescription)
        return self.currentWeatherDescription;
    else
        return @"";
}

- (UIImage *) imageWithIconName:(NSString *)iconName {
    return [self.iconNames objectForKey:iconName];
}

# pragma mark - weather data retrieval

- (void)makeCurrentWeatherRequestWithLat: (double) latitude Lon: (double) longitude {
    // create the url for the request
    NSString *urlAsString = [NSString stringWithFormat: @"http://api.openweathermap.org/data/2.5/weather?lat=%d&lon=%d&APPID=%@",
                             (int)latitude, (int)longitude, APIKEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [self makeCurrentWeatherRequestWithURL:url];
}


- (void) makeCurrentWeatherRequestWithZipCode: (NSString *) zipCode CountryCode: (NSString *) countryCode {
    // create the url for the request
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?zip=%@,%@&APPID=%@",
                             zipCode, countryCode, APIKEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [self makeCurrentWeatherRequestWithURL:url];
}

- (void) makeWeatherForecastRequestWithLat: (double) latitude Lon: (double) longitude {
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%d&lon=%d&APPID=%@",
                             (int)latitude, (int)longitude, APIKEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            NSLog(@"Connection Error");
        }
        else {
            [self parseWeatherForecastData: data];
        }
    }];
}

- (void) makeCurrentWeatherRequestWithURL: (NSURL *) url {
    // make the actual request
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            NSLog(@"Connection Error");
            self.currentWeatherDescription = CHECKCONNECTION;
        }
        else {
            // call method to organize that data
            [self parseCurrentWeatherData: data];
        }
    }];
}

- (void)parseCurrentWeatherData: (NSData *) data {
    
    // local variables to produce currentWeatherDescription
    NSNumber *temp;
    NSString *description;
    
    if (data == nil) {
        NSLog(@"NO DATA");
        // change??
        self.currentWeatherDescription = CHECKCONNECTION;
        return;
    }
    
    NSError *error = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        // try again?
        NSLog(@"Error parsing json object");
//        [self updateWeather];
            self.currentWeatherDescription = CHECKCONNECTION;
    }
    else {
        NSDictionary *results = parsedObject[MAINKEY]; 
        
        // set the temperature, convert to F
        temp =  results[TEMPKEY]; //[results valueForKey:TEMPKEY];
        temp = [self kelvinToFahrenheit:temp.doubleValue];
        
        results = parsedObject[WEATHERKEY];
        
        // if there is a description in the dictionary
        NSArray *descriptionArray = [results valueForKey:DESCRIPTIONKEY];
        if(descriptionArray.count != 0) {
            description = descriptionArray[0];
            description = [description capitalizedString];
        }
        
        NSArray *iconArray = [results valueForKey:@"icon"];
        if(iconArray.count != 0) {
            self.currentWeatherIconName = iconArray[0];
        }
        
        self.currentWeatherDescription = [NSString stringWithFormat:@"Currently: %@°F, %@", temp, description];
        self.shortWeatherDescription = description;
        self.currentTemperature = temp;
         NSLog(@"%@", self.currentWeatherDescription);
        
        results = nil;
        descriptionArray = nil;
        iconArray = nil;
    }
    temp = nil;
    description = nil;
}

- (NSNumber *) kelvinToFahrenheit: (double)kelvin {
    double result = ((kelvin - 273.15) * 1.8) + 32;
    return [NSNumber numberWithDouble:ceil(result)];
}

- (void) parseWeatherForecastData: (NSData *)data {
    
    if (data == nil) {
        NSLog(@"NO DATA");
        return;
    }
    
    NSError *error = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        // try again?
        NSLog(@"Error parsing json object");
        // errors here are different... Any errors and something MUST be done.. but what?
    }
    else {
        // get the "list" of the forecast data
        NSDictionary *results = parsedObject[LIST];

        NSEnumerator *enumerator = [results objectEnumerator];
        NSDictionary *dict;
        
        // want the first 4 forecast weather data entries
        for (int i = 0; i < 4; ++i) {
            dict = [enumerator nextObject];
            if(dict) {
                NSNumber *temperature =[[dict objectForKey:MAINKEY] objectForKey:TEMPKEY];
                [self.forecastTemperatures addObject: [self kelvinToFahrenheit:temperature.doubleValue]];
                NSDictionary *weatherDict = [dict objectForKey:WEATHERKEY][0];
                [self.forecastIcons addObject: [weatherDict objectForKey:ICON]];
                [self.forecastTimes addObject: [dict objectForKey:TIME]];
                temperature = nil;
                weatherDict = nil;
            }
        }
        
        results = nil;
    }
}


@end

//api.openweathermap.org/data/2.5/forecast/city?id=524901&APPID=d5e9f812c964d56ef5c3b8c0edb13847
//http://api.openweathermap.org/data/2.5/weather?zip=94040,us&APPID=d5e9f812c964d56ef5c3b8c0edb13847
// x-api-key:d5e9f812c964d56ef5c3b8c0edb13847 - add this to the header