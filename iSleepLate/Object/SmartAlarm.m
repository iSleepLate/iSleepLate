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

#pragma mark - MApKit

- (void)calculateETAToDestination:(MKMapItem *)destination
{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionsRequest.destination = destination;
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = YES;
    directionsRequest.arrivalDate = self.dateOfArrival;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Directions Error: %@", error.localizedDescription);
        } else {
            self.expectedTravelTime = response.expectedTravelTime;
        }
    }];
}

@end
