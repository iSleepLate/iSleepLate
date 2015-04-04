//
//  SelectDestinationViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/21/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "DestinationViewController.h"
#import "GeocodeResultsViewController.h"
#import "PreparationTimeViewController.h"
#import "SmartAlarm.h"

@import MapKit;
@import AddressBook;

@interface DestinationViewController () <UITextFieldDelegate, GeocodeResultsDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) NSArray *searchResults;
@property (strong, nonatomic) NSMutableArray *placemarks;

@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation DestinationViewController

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _placemarks = [NSMutableArray array];
    }
    
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showGeocodeResults"]) {
        GeocodeResultsViewController *geocodeResultsVC = segue.destinationViewController;
        geocodeResultsVC.delegate = self;
        geocodeResultsVC.geocodeResults = self.placemarks;
    } else if ([segue.identifier isEqualToString:@"showPrepTime"]) {
        PreparationTimeViewController *prepTimeVC = segue.destinationViewController;
        prepTimeVC.alarm = self.alarm;
    }
}

#pragma mark - IBActions

- (IBAction)segueButtonPressed:(id)sender
{
    [self.activityIndicator startAnimating];
    [self.placemarks removeAllObjects];
    [self performLocalSearchOfDestination:self.addressField.text];
}

#pragma mark - Private Methods

- (void)performLocalSearchOfDestination:(NSString *)destination
{
    MKCoordinateRegion region;
    region.center = self.alarm.currentLocation.placemark.coordinate;
    region.span = MKCoordinateSpanMake(1.0, 1.0); // in degrees, not km
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = destination;
    request.region = region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [self.activityIndicator stopAnimating];
        if (error) {
            NSLog(@"Local Search Error: %@", error.localizedDescription);
        } else {
            for (MKMapItem *mapItem in response.mapItems) {
                [self.placemarks addObject:mapItem.placemark];
            }
            [self performSegueWithIdentifier:@"showGeocodeResults" sender:self];
        }
    }];
}

#pragma mark - UITextFieldDelegate

// called when user presses enter
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // hide the keyboard
    [textField resignFirstResponder];
    
    [self performLocalSearchOfDestination:self.addressField.text];
    
    return YES;
}

#pragma mark - GeocodeResultsDelegate

- (void)userDidPickerPlacemark:(CLPlacemark *)placemark
{
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];
    self.alarm.destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [self.presentedViewController dismissViewControllerAnimated:NO completion:^{
        sleep(0.25);
        [self performSegueWithIdentifier:@"showPrepTime" sender:self];
    }];
}

@end
