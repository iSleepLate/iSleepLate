//
//  AlarmSummaryViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AlarmSummaryViewController.h"
#import "SmartAlarm.h"
#import "AppDelegate.h"

@import AddressBook;

@interface AlarmSummaryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *arrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ETALabel;
@property (weak, nonatomic) IBOutlet UILabel *prepTimeLabel;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation AlarmSummaryViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Alarm Summary";
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        self.currentLocation = appDelegate.currentLocation;
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.arrivalLabel.text = [self stringFromDateOfArrival];
    if (self.alarm.expectedTravelTime) {
        self.destinationLabel.text = [self prettyStringFromMapItem:self.alarm.destination];
        self.ETALabel.text = [self prettyStringFromTravelTime:self.alarm.expectedTravelTime];
    } else {
        [self.alarm addObserver:self
                     forKeyPath:@"expectedTravelTime"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
    }
    self.prepTimeLabel.text = [self stringFromPrepartionTime];
    
    [self reverseGeocodeCurrentLocation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    self.destinationLabel.text = [self prettyStringFromMapItem:self.alarm.destination];
    self.ETALabel.text = [self prettyStringFromTravelTime:self.alarm.expectedTravelTime];
}

- (void)reverseGeocodeCurrentLocation
{
    self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder reverseGeocodeLocation:self.currentLocation
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            if (error) {
                                NSLog(@"Reverse Geocode Error: %@", error.localizedDescription);
                            } else if (placemarks.count == 0) {
                                NSLog(@"Invalid request");
                            } else if (placemarks.count > 1) {
                                NSLog(@"Too many results returned");
                            } else {
                                MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
                                MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
                                self.currentLocationLabel.text = [self prettyStringFromMapItem:mapItem];
                            }
                        }];
}

- (NSString *)stringFromDateOfArrival
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    return [formatter stringFromDate:self.alarm.dateOfArrival];
}

- (NSString *)stringFromPrepartionTime
{
    int min = self.alarm.preparationTime.location;
    int max = min + self.alarm.preparationTime.length;
    return [NSString stringWithFormat:@"Min: %d, Max: %d", min, max];
}

//- (void)calculateETAToDestination:(MKMapItem *)destination
//{
//    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
//    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
//    directionsRequest.destination = destination;
//    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
//    directionsRequest.requestsAlternateRoutes = YES;
//    directionsRequest.arrivalDate = self.alarm.dateOfArrival;
//    
//    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
//    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Directions Error: %@", error.localizedDescription);
//        } else {
//            self.destinationLabel.text = [self prettyStringFromMapItem:destination];
//            self.ETALabel.text = [self prettyStringFromETAResponse:response];
//        }
//    }];
//}

- (NSString *)prettyStringFromTravelTime:(NSTimeInterval)travelTime
{
    int seconds = (int)travelTime;
    int hours = seconds / 3600;
    seconds -= (hours * 3600);
    int minutes = seconds / 60;
    seconds -= minutes * 60;
    
    return [NSString stringWithFormat:@"%dh %dm %ds", hours, minutes, seconds];
}

- (NSString *)prettyStringFromMapItem:(MKMapItem *)mapItem
{
    NSDictionary *addressDictionary = mapItem.placemark.addressDictionary;
    NSString *street = addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
    NSString *city = addressDictionary[(__bridge NSString *) kABPersonAddressCityKey];
    NSString *state = addressDictionary[(__bridge NSString *) kABPersonAddressStateKey];
    NSString *zip = addressDictionary[(__bridge NSString *) kABPersonAddressZIPKey];
    
    return [NSString stringWithFormat:@"%@, %@, %@ %@", street, city, state, zip];
}

@end
