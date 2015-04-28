//
//  WakeUpViewController.m
//  iSleepLate
//
//  Created by Laura Humphries on 4/20/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "WakeUpViewController.h"
#import "AppDelegate.h"

// remove this later and have a weather view 
#define WEATHERURL @"https://www.weather.yahoo.com"
#define TABLEITEMS 2

@implementation WakeUpViewController

@synthesize timeLabel;
@synthesize alarm;
@synthesize currentLocation;
@synthesize notificationItems;
@synthesize slideToUnlockView;
@synthesize shimmeringView;


- (id) init {
    self = [super init];
    if (self) {
        self.notificationItems = @[@"Weather", @"Traffic"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    // update labels
    [self updateTime];
    [self updateLeaveByTime];
    
    // get reference to app delegate for the currentLocation
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.alarm = [appDelegate alarm];
    self.currentLocation = appDelegate.currentLocation;
    self.weather = appDelegate.weather;
    
    // set up gesture recognizer for slide to unlock view
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.slideToUnlockView addGestureRecognizer:swiperight];
    
    // start shimmering
    self.shimmeringView.contentView = self.slideToHideImage;
    
    self.shimmeringView.shimmering = YES;
    [self.shimmeringView  setShimmeringOpacity:0.3];
    [self.shimmeringView  setShimmeringAnimationOpacity:1];
    [self.shimmeringView  setShimmeringSpeed:100];
}

- (void)updateTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    NSString *time = [formatter stringFromDate:[NSDate date]];
    time = [time stringByTrimmingCharactersInSet:[NSCharacterSet letterCharacterSet]];      // remove AM/PM
    time = [time stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.timeLabel.text = time;
}

- (void)updateLeaveByTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    NSString *leaveByTime = [formatter stringFromDate:[self.alarm leaveByTime]];
    self.leaveByLabel.text = [NSString stringWithFormat:@"Leave by %@", leaveByTime];
}

#pragma mark - Slide to unlock

// want to work with the animation more!! to abrupt
- (void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer{
//    NSLog(@"Swipe to UNLOCK!!!");
    
    // push to the ArrivalTimeController
//    [self performSegueWithIdentifier:@"BackToArrival" sender:self];
    
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
//        [self.presentingViewController.presentingViewController.navigationController popToRootViewControllerAnimated:YES];
    }];
    // can't do because we've lost the navigation controller
//    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        // iOS 7 separator
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)configureCell:(MCSwipeTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // use orange color? or clear color?
    UIView *checkView = [[UIView alloc] init];
    
    
    // Setting the default inactive state color to the tableView background color
    [cell setDefaultColor:[UIColor clearColor]];
    
    if (indexPath.row % TABLEITEMS == 0) {
        [cell.textLabel setText:@"Weather"];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        [cell.detailTextLabel setText:[self.weather getWeatherDescription]];
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        [cell setSwipeGestureWithView:checkView color:[UIColor clearColor] mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
            NSLog(@"Did swipe to go to Weather Screen");
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:WEATHERURL]];
            [self performSegueWithIdentifier:@"ToWeatherDetailsViewController" sender:self];
        }];
    }
    else if (indexPath.row % TABLEITEMS == 1) {
        [cell.textLabel setText:@"Traffic"];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"Travel time Is %@ minutes", [self.alarm expectedTravelTimeString]]];
        [[cell detailTextLabel] setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size: 12]];
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        
        [cell setSwipeGestureWithView:checkView color:[UIColor clearColor] mode:MCSwipeTableViewCellModeExit state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {

            [self openMaps];
        }];
    }
    
}

- (void) openMaps {
    // if we can open google maps..
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        
        CLLocationCoordinate2D start = self.currentLocation.coordinate;
        CLLocationCoordinate2D destination = self.alarm.destination.placemark.location.coordinate;
        
        NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
                                         start.latitude, start.longitude, destination.latitude, destination.longitude];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
        
        // ***** some kind of return to app thing ***** that would be awesome!
        
    }
    // can't use google maps, use default apple maps
    else {
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        [self.alarm.destination openInMapsWithLaunchOptions:launchOptions];
        
        // ** impossible to return to app according to something I saw?? **
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

#pragma mark - Table view delegate


// action when they touch the cell.. we don't want this!!
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // when the user selects a row, nothing will happen - must SWIPE
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MCSwipeTableViewCellDelegate

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
         NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
         NSLog(@"Did end swiping the cell!");
}


#pragma mark - Utils

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}



@end
