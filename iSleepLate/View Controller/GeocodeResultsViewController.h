//
//  GeocodeResultsViewController.h
//  iSleepLate
//
//  Created by David Neubauer on 4/1/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

@protocol GeocodeResultsDelegate <NSObject>

- (void)userDidPickerPlacemark:(CLPlacemark *)placemark;

@end

@interface GeocodeResultsViewController : UIViewController

// NSArray of CLPlacemark Objects
@property (strong, nonatomic) NSArray *geocodeResults;

@property (nonatomic) id<GeocodeResultsDelegate> delegate;

@end
