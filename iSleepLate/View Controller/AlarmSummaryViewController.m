//
//  AlarmSummaryViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "AlarmSummaryViewController.h"
#import "SmartAlarm.h"

@import AddressBook;

@interface AlarmSummaryViewController ()

@property (weak, nonatomic) IBOutlet UILabel *arrivalLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ETALabel;
@property (weak, nonatomic) IBOutlet UILabel *prepTimeLabel;

@end

@implementation AlarmSummaryViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.title = @"Alarm Summary";
        
        NSRange prepTime;
        prepTime.location = 10; // Min: 10min
        prepTime.length = 30;   // Max: 40min
        
        self.alarm.preparationTime = prepTime;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [self.alarm addObserver:self
                 forKeyPath:@"destination"
                    options:NSKeyValueObservingOptionNew
                    context:NULL];
    
    self.arrivalLabel.text = [self stringFromDateOfArrival];
    if (self.alarm.destination) {
        [self calculateETAToDestination:self.alarm.destination];
    }
    self.prepTimeLabel.text = [self stringFromPrepartionTime];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"destination"]) {
        [self calculateETAToDestination:self.alarm.destination];
    }
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

- (void)calculateETAToDestination:(MKMapItem *)destination
{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionsRequest.destination = destination;
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = YES;
    directionsRequest.arrivalDate = self.alarm.dateOfArrival;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Directions Error: %@", error.localizedDescription);
        } else {
            self.destinationLabel.text = [self prettyStringFromMapItem:destination];
            self.ETALabel.text = [self prettyStringFromETAResponse:response];
        }
    }];
}

- (NSString *)prettyStringFromETAResponse:(MKETAResponse *)response
{
    int seconds = response.expectedTravelTime;
    int hours = seconds / 3600;
    seconds -= (hours * 3600);
    int minutes = seconds / 60;
    seconds -= minutes * 60;
    
    return [NSString stringWithFormat:@"%dH %dM %dS.", hours, minutes, seconds];
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
