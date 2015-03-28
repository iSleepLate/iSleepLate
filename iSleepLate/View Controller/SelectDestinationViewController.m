//
//  SelectDestinationViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 3/21/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SelectDestinationViewController.h"

@import MapKit;
//@import CoreLocation;
@import AddressBookUI;

static CGFloat const MapRegionSpanDistance = 0.02;  // in kilometers
static CGFloat const LocalSearchSpanDistance = 5;   // in kilometers

@interface SelectDestinationViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *searchResultsTable;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBetweenTableViewAndBottomMargin;

@end

@implementation SelectDestinationViewController

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // hide tableview at first
    self.searchResultsTable.hidden = YES;
 
    [self registerForKeyboardNotifications];
    [self zoomToUsersCurrentLocation];
}

#pragma mark - Private Methods


- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:@"UIKeyboardDidShowNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
    
}

- (void)updateMapViewRegion
{
    MKCoordinateRegion mapRegion;
    mapRegion.center = self.mapView.userLocation.coordinate;
    mapRegion.span = MKCoordinateSpanMake(MapRegionSpanDistance, MapRegionSpanDistance);
    
    [self.mapView setRegion:mapRegion animated:YES];
}

- (void)zoomToUsersCurrentLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // neccessary iOS 8+
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.mapView.showsUserLocation = YES;   // sufficient for < iOS 8
    
//    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)performLocalSearchWithQuery:(NSString *)query
{
    MKCoordinateRegion region = self.mapView.region;
    region.span = MKCoordinateSpanMake(LocalSearchSpanDistance, LocalSearchSpanDistance);
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    request.region = self.mapView.region;//region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error) {
            NSLog(@"MKLocalSearchRequest could not complete request. Encounter error: %@", error.localizedDescription);
        } else {
            self.searchResults = response.mapItems;
            [self.searchResultsTable reloadData];
        }
    }];
}

- (NSString *)addressFromMapItem:(MKMapItem *)mapItem
{
    NSDictionary *addressDict = mapItem.placemark.addressDictionary;
    return ABCreateStringWithAddressDictionary(addressDict, NO);
}

#pragma mark - NSNotifications

#pragma mark - Keyboard Notifications

// shrink tableview when keyboard shows
- (void)keyboardDidShow:(NSNotification *)note
{
    NSDictionary *info = [note userInfo];
    CGRect kbFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.spaceBetweenTableViewAndBottomMargin.constant = kbFrame.size.height;
}

// grow tableview when keyboard hides
- (void)keyboardWillHide:(NSNotification *)note
{
    self.spaceBetweenTableViewAndBottomMargin.constant = 0;
}

#pragma mark - Protocol Conformance

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Updated: %d locations", locations.count);
//    [self.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark - CLLocationManagerDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self updateMapViewRegion];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults ? self.searchResults.count + 1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    } else {
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = self.textField.text;
        cell.detailTextLabel.text = @"";
    } else if (indexPath.row - 1 < self.searchResults.count) {
        MKMapItem *mapItem = self.searchResults[indexPath.row - 1];
        cell.textLabel.text = mapItem.name;
        cell.detailTextLabel.text = [self addressFromMapItem:mapItem];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.textField resignFirstResponder];
    
    [tableView deselectRowAtIndexPath:indexPath animated:indexPath.row];
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    if (indexPath.row == 0) {   // show search results on map
        for (MKMapItem *mapItem in self.searchResults) {
            MKPointAnnotation *pointAnnotation = [MKPointAnnotation new];
            pointAnnotation.coordinate = mapItem.placemark.location.coordinate;
            [self.mapView addAnnotation:pointAnnotation];
        }
    } else if (indexPath.row - 1 < self.searchResults.count){
        MKMapItem *mapItem = self.searchResults[indexPath.row - 1];
        MKPointAnnotation *pointAnnotation = [MKPointAnnotation new];
        pointAnnotation.coordinate = mapItem.placemark.location.coordinate;
        [self.mapView addAnnotation:pointAnnotation];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.searchResultsTable.hidden = NO;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.searchResultsTable.hidden = YES;
}

// called when user presses enter
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // hide the keyboard
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    NSString *searchQuery = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (searchQuery.length > 0) {
        [self performLocalSearchWithQuery:searchQuery];
    }
    
    return YES;
}

@end
