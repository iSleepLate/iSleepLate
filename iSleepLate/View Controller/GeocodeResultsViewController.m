//
//  GeocodeResultsViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/1/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "GeocodeResultsViewController.h"
#import "PreparationTimeViewController.h"

@import AddressBook;
@import QuartzCore;

@interface GeocodeResultsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *resultsTable;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightContraint;

@end

@implementation GeocodeResultsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.resultsTable.rowHeight = 50.0;
    self.resultsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.resultsTable.layer.cornerRadius = 10.0;
    self.tableViewHeightContraint.constant = 40 + 50.0 * MIN(self.geocodeResults.count, 4);
}

/* EVENTUALLY MOVE ALL THESE HELPER METHODS INTO A MAPKIT CATEGORY */

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark
{
    NSDictionary *addressDictionary = placemark.addressDictionary;
    NSString *street = addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
    NSString *city = addressDictionary[(__bridge NSString *) kABPersonAddressCityKey];
    NSString *state = addressDictionary[(__bridge NSString *) kABPersonAddressStateKey];
//    NSString *zip = addressDictionary[(__bridge NSString *) kABPersonAddressZIPKey];
    
    return [NSString stringWithFormat:@"%@\n%@, %@", street, city, state];
}

/*******************************************************************/

#pragma mark - IBAction

- (IBAction)cancelSelection:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 40)];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithRed:9/255.0 green:67/255.0 blue:101/255.0 alpha:1.0];
    label.text = [NSString stringWithFormat:@"Results (%d)", self.geocodeResults.count];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17.0];
    
    return label;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.geocodeResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    CLPlacemark *placemark = self.geocodeResults[indexPath.row];
    NSDictionary *addressDictionary = placemark.addressDictionary;
    NSString *street = addressDictionary[(__bridge NSString *) kABPersonAddressStreetKey];
    NSString *city = addressDictionary[(__bridge NSString *) kABPersonAddressCityKey];
    NSString *state = addressDictionary[(__bridge NSString *) kABPersonAddressStateKey];
    
    cell.textLabel.text = street;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor colorWithRed:9/255.0 green:67/255.0 blue:101/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:9/255.0 green:67/255.0 blue:101/255.0 alpha:1.0];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLPlacemark *placemark = self.geocodeResults[indexPath.row];
    [self.delegate userDidPickerPlacemark:placemark];
}

@end
