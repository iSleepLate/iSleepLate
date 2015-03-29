//
//  SelectDestinationViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/21/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SelectDestinationViewController.h"

@import MapKit;
@import AddressBook;

@interface SelectDestinationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) NSArray *searchResults;

@property (weak, nonatomic) IBOutlet UITextField *addressField;

@end

@implementation SelectDestinationViewController

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    
    return self;
}

#pragma mark - IBActions

- (IBAction)saveDestination:(id)sender
{
    [self geocodeAddressString:self.addressField.text];
}


#pragma mark - Private Methods

- (void)geocodeAddressString:(NSString *)addressString
{
    self.geocoder = [[CLGeocoder alloc] init];
    [self.geocoder geocodeAddressString:addressString
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          if (error) {
                              NSLog(@"Geocode Error: %@", error.localizedDescription);
                          } else if (placemarks.count == 0) {
                              NSLog(@"Invalid request");
                          } else if (placemarks.count > 1) {
                              NSLog(@"Too many results returned");
                          } else {
                              MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:placemarks[0]];
                              MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
                              [self calculateETAToDestination:destination];
                          }
                      }];
}

- (void)calculateETAToDestination:(MKMapItem *)destination
{
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    directionsRequest.source = [MKMapItem mapItemForCurrentLocation];
    directionsRequest.destination = destination;
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    directionsRequest.requestsAlternateRoutes = NO;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Directions Error: %@", error.localizedDescription);
        } else {
            NSLog(@"%@", [self prettyStringFromETAResponse:response]);
        }
    }];
}

- (NSString *)prettyStringFromETAResponse:(MKETAResponse *)response
{
    NSString *source = [self prettyStringFromMapItem:response.source];
    NSString *destination = [self prettyStringFromMapItem:response.destination];
    int seconds = response.expectedTravelTime;
    int hours = seconds / 3600;
    seconds -= (hours * 3600);
    int minutes = seconds / 60;
    seconds -= minutes * 60;
    
    return [NSString stringWithFormat:@"Travel time from %@ to %@ is %dH %dM %dS.", source, destination, hours, minutes, seconds];
}

- (NSString *)prettyStringFromMapItem:(MKMapItem *)mapItem
{
    __block NSDictionary *addressDictionary = mapItem.placemark.addressDictionary;
    if (!addressDictionary) {
        [self.geocoder reverseGeocodeLocation:mapItem.placemark.location
                            completionHandler:^(NSArray *placemarks, NSError *error) {
                                if (error) {
                                    NSLog(@"Reverse Geolocation Error: %@", error.localizedDescription);
                                } else if (placemarks.count > 0) {
                                    CLPlacemark *placemark = placemarks[0];
                                    addressDictionary = placemark.addressDictionary;
                                    
//                                    NSString *street = addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
//                                    NSString *city = addressDictionary[(__bridge NSString *) kABPersonAddressCityKey];
//                                    NSString *state = addressDictionary[(__bridge NSString *) kABPersonAddressStateKey];
//                                    NSString *zip = addressDictionary[(__bridge NSString *) kABPersonAddressZIPKey];
//                                    
//                                    return [NSString stringWithFormat:@"%@, %@, %@ %@", street, city, state, zip];
                                }
                            }];
    } else {
        NSString *street = addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
        NSString *city = addressDictionary[(__bridge NSString *) kABPersonAddressCityKey];
        NSString *state = addressDictionary[(__bridge NSString *) kABPersonAddressStateKey];
        NSString *zip = addressDictionary[(__bridge NSString *) kABPersonAddressZIPKey];
        
        return [NSString stringWithFormat:@"%@, %@, %@ %@", street, city, state, zip];
    }
    
    return nil;
}

#pragma mark - UITextFieldDelegate

// called when user presses enter
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // hide the keyboard
    [textField resignFirstResponder];
    
    return YES;
}

@end
