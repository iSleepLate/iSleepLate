//
//  SettingsViewController.m
//  iSleepLate
//
//  Created by Doug Waters on 4/8/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"

@interface SettingsViewController () <UITableViewDataSource>

@property (strong, nonatomic) NSArray *rowIds;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideMenuButton;
@property (strong, nonatomic) UISwitch *snoozeSwitch;

@end

@implementation SettingsViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _rowIds = @[@"sound", @"snooze"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.snoozeSwitch.layer.cornerRadius = 16;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.rowIds[indexPath.row]];
    if ([self.rowIds[indexPath.row] isEqualToString:@"snooze"]) {
        self.snoozeSwitch = [[UISwitch alloc] init];
        self.snoozeSwitch.onTintColor = [UIColor redColor];
        self.snoozeSwitch.backgroundColor = [UIColor grayColor];
        self.snoozeSwitch.layer.cornerRadius = 16.0;
        [self.snoozeSwitch addTarget:self
                              action:@selector(snoozeSwitchToggled:)
                    forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = self.snoozeSwitch;
    }
    return cell;
}

#pragma mark - UIControl

- (void)snoozeSwitchToggled:(id)sender
{
    NSLog(@"Switch State: %d", self.snoozeSwitch.on);
    [[NSUserDefaults standardUserDefaults] setBool:self.snoozeSwitch.on forKey:@"snoozeEnabled"];
}

@end
