//
//  WeatherDetails.m
//  iSleepLate
//
//  Created by Laura Humphries on 4/7/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//
//  This weather details object is used to represent the data that will be shown to the user when they wake up

#import "WeatherObject.h"
#import "AppDelegate.h"
#import "SmartAlarm.h"

#define APIKEY @"d5e9f812c964d56ef5c3b8c0edb13847"
#define MAINKEY @"main"
#define TEMPKEY @"temp"
#define WEATHERKEY @"weather"
#define DESCRIPTIONKEY @"description"



@implementation WeatherObject

- (id) init {
    self = [super init];
    self.currentWeatherDescription = nil;
    // travel time!!
    return self;
}


- (void) updateWeather{
    
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
            [self makeRequestWithLat:currentLocation.coordinate.latitude Lon:currentLocation.coordinate.longitude];
            
        }
        else {
            // We only want to make the request once, since multiple placemarks we make multiple in one pass - how to fix??
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *countryCode = placemark.ISOcountryCode;
            NSString *zipCode = placemark.postalCode;
            
            [self makeRequestWithZipCode:zipCode CountryCode:countryCode];
        }
    }];
}

- (NSString *)getWeatherDescription {
    if (self.currentWeatherDescription)
        return self.currentWeatherDescription;
    else
        return @"";
}

- (void)makeRequestWithLat: (double) latitude Lon: (double) longitude {
    // create the url for the request
    NSString *urlAsString = [NSString stringWithFormat: @"http://api.openweathermap.org/data/2.5/weather?lat=%d&lon=%d&APPID=%@",
                             (int)latitude, (int)longitude, APIKEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [self makeRequestWithURL:url];
    
}


- (void)makeRequestWithZipCode: (NSString *) zipCode CountryCode: (NSString *) countryCode {
    // create the url for the request
    NSString *urlAsString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?zip=%@,%@&APPID=%@",
                             zipCode, countryCode, APIKEY];
    NSURL *url = [[NSURL alloc] initWithString:urlAsString];
    
    [self makeRequestWithURL:url];
    
}

- (void)makeRequestWithURL: (NSURL *) url {
    
    // make the actual request
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(connectionError) {
            // try again?
            NSLog(@"Connection Error");
            [self updateWeather];
        }
        else {
            // call method to organize that data
            [self receivedJSON: data];
        }
    }];
}

- (void)receivedJSON: (NSData *) data {
    
    // local variables to produce currentWeatherDescription
    NSNumber *temp;
    NSString *description;
    
    if (data == nil) {
        NSLog(@"NO DATA");
        return;
    }
    
    NSError *error = nil;
    NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        // try again?
        NSLog(@"Error parsing json object");
        [self updateWeather];
    }
    else {
        NSDictionary *results = parsedObject[MAINKEY]; //[parsedObject valueForKey:MAINKEY];
        
        // set the temperature, convert to F
        temp =  results[TEMPKEY]; //[results valueForKey:TEMPKEY];
        temp = [self kelvinToFahrenheit:temp];
        
        results = parsedObject[WEATHERKEY];
        
        // if there is a description in the dictionary
        NSArray *descriptionArray = [results valueForKey:DESCRIPTIONKEY];
        if(descriptionArray.count != 0) {
            description = descriptionArray[0];
            description = [description capitalizedString];
        }
        
        self.currentWeatherDescription = [NSString stringWithFormat:@"Currently: %@°F, %@", temp, description];
        NSLog(@"%@", self.currentWeatherDescription);
        
        results = nil;
    }
}


- (NSNumber *) kelvinToFahrenheit: (NSNumber *)kelvin {
    double result = (([kelvin doubleValue] - 273.15) * 1.8) + 32;
    return [NSNumber numberWithDouble:ceil(result)];
}


@end

//api.openweathermap.org/data/2.5/forecast/city?id=524901&APPID=d5e9f812c964d56ef5c3b8c0edb13847
//http://api.openweathermap.org/data/2.5/weather?zip=94040,us&APPID=d5e9f812c964d56ef5c3b8c0edb13847
// x-api-key:d5e9f812c964d56ef5c3b8c0edb13847 - add this to the header