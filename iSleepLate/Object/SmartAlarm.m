//
//  SmartAlarm.m
//  iSleepLate
//
//  Created by David Neubauer on 3/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SmartAlarm.h"

@implementation SmartAlarm

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self
               forKeyPath:@"destination"
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
    }
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
    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionsRequest.destination = destination;
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = YES;
    directionsRequest.arrivalDate = self.dateOfArrival;

    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Directions Error: %@", error.localizedDescription);
        } else {
            for (MKRoute *route in response.routes) {
                self.expectedTravelTime += route.expectedTravelTime;
            }
        }
    }];
}

@end
