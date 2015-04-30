//
//  WeatherDetailsViewController.h
//  iSleepLate
//
//  Created by Laura Humphries on 4/24/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherIconView.h"

@interface WeatherDetailsViewController : UIViewController

// current weather data labels
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentDayLabel;
@property (weak, nonatomic) IBOutlet WeatherIconView *currentWeatherIcon;
@property (weak, nonatomic) IBOutlet UILabel *currentTemperatureLabel2;

// weather forecast labels

// highs and lows
@property (weak, nonatomic) IBOutlet UILabel *highTemperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *lowTemperatureLabel;

// 3 hour data labels

// first 3 hour labels
@property (weak, nonatomic) IBOutlet UILabel *hourLabel1;
@property (weak, nonatomic) IBOutlet WeatherIconView *weatherIcon1;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel1;

// second 3 hour labels
@property (weak, nonatomic) IBOutlet UILabel *hourLabel2;
@property (weak, nonatomic) IBOutlet WeatherIconView *weatherIcon2;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel2;

// third 3 hour labels
@property (weak, nonatomic) IBOutlet UILabel *hourLabel3;
@property (weak, nonatomic) IBOutlet WeatherIconView *weatherIcon3;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel3;

// fourth 3 hour labels
@property (weak, nonatomic) IBOutlet UILabel *hourLabel4;
@property (weak, nonatomic) IBOutlet WeatherIconView *weatherIcon4;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel4;

@end
