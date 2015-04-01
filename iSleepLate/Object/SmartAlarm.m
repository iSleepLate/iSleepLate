//
//  SmartAlarm.m
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SmartAlarm.h"
#import "AppDelegate.h"

@import AddressBook;

@interface SmartAlarm ()

@property (strong, nonatomic) UILocalNotification *localNotification;

@end

@implementation SmartAlarm

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self
               forKeyPath:@"destination"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        [appDelegate addObserver:self
                      forKeyPath:@"currentLocation"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    }
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"destination"] && self.destination) {
        [self calculateETAToDestination:self.destination];
    } else if ([keyPath isEqualToString:@"currentLocation"]) {
        AppDelegate *appDelegate = object;
        [self reverseGeocodeLocation:appDelegate.currentLocation];
    }
}

#pragma mark - Printing Out Alarm Info

- (void)printAlarmInfo
{
    [self printDateOfArrival];
    [self printPrepartionTime];
    [self printMapItem:self.currentLocation];
    [self printMapItem:self.destination];
    [self printTravelTime:self.expectedTravelTime];
}

- (void)printDateOfArrival
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSLog(@"Arrival Date: %@",[formatter stringFromDate:self.dateOfArrival]);
}

- (void)printPrepartionTime
{
    NSUInteger min = self.preparationTime.location;
    NSUInteger max = min + self.preparationTime.length;
    NSLog(@"Min: %u, Max: %u", min, max);
}

- (void)printTravelTime:(NSTimeInterval)travelTime
{
    int seconds = (int)travelTime;
    int hours = seconds / 3600;
    seconds -= (hours * 3600);
    int minutes = seconds / 60;
    seconds -= minutes * 60;
    
    NSLog(@"%dh %dm %ds", hours, minutes, seconds);
}

- (void)printMapItem:(MKMapItem *)mapItem
{
    NSDictionary *addressDictionary = mapItem.placemark.addressDictionary;
    NSString *street = addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
    NSString *city = addressDictionary[(__bridge NSString *) kABPersonAddressCityKey];
    NSString *state = addressDictionary[(__bridge NSString *) kABPersonAddressStateKey];
    NSString *zip = addressDictionary[(__bridge NSString *) kABPersonAddressZIPKey];
    
    NSLog(@"%@, %@, %@ %@", street, city, state, zip);
}

#pragma mark - MapKit


// Notice that this method calls calculateDirections() NOT
// calculateETA(), which Apple says is a quicker estimate.
// According to the tests I ran, it seems calculateETA() does
// not take into consideration the arrivalTime of the directionsRequest.
// Ex. Berkeley -> Apple HQ at 5:30PM
//     calculateDirections(): ~2hr
//     calculateETA():        ~1hr
- (void)calculateETAToDestination:(MKMapItem *)destination
{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    directionsRequest.source = self.currentLocation;
    directionsRequest.destination = destination;
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = YES;
    directionsRequest.arrivalDate = self.dateOfArrival;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Directions Error: %@", error.localizedDescription);
        } else {
            self.expectedTravelTime = 0;
            for (MKRoute *route in response.routes) {
                self.expectedTravelTime += route.expectedTravelTime;
            }
        }
    }];
}

- (void)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        if (error) {
                            NSLog(@"Reverse Geocode Error: %@", error.localizedDescription);
                        } else if (placemarks.count == 0) {
                            NSLog(@"Invalid request");
                        } else if (placemarks.count > 1) {
                            NSLog(@"Too many results returned");
                        } else {
                            MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
                            self.currentLocation = [[MKMapItem alloc] initWithPlacemark:placemark];
                        }
                    }];
}

#pragma mark - Notifications

- (void)scheduleLocalNotification
{
    NSTimeInterval maxPrepTime = 60 * (self.preparationTime.location + self.preparationTime.length); // minutes
    NSDate *fireDate = [self.dateOfArrival dateByAddingTimeInterval: -(self.expectedTravelTime + maxPrepTime)];
    
    self.localNotification = [[UILocalNotification alloc] init];
    self.localNotification.fireDate = fireDate;
    self.localNotification.timeZone = [NSTimeZone defaultTimeZone];
    self.localNotification.alertBody = @"Wake Up!";
    self.localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:self.localNotification];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSLog(@"Local Notification set for %@", [formatter stringFromDate:fireDate]);
}

- (void)cancelScheduledLocalNotification
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [[UIApplication sharedApplication] cancelLocalNotification:self.localNotification];
    NSLog(@"Local Notification for %@ cancelled", [formatter stringFromDate:self.localNotification.fireDate]);
}

@end
