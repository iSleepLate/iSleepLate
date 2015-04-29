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
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISwitch *snoozeSwitch;

@end

@implementation SettingsViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _rowIds = @[@"snooze", @"prepTime"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.snoozeSwitch.layer.cornerRadius = 16;
    self.tableView.tableFooterView = [UIView new];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if (revealViewController) {
        [self.sideMenuButton setTarget: self.revealViewController];
        [self.sideMenuButton setAction: @selector(revealToggle:)];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rowIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.rowIds[indexPath.row]];
    if ([self.rowIds[indexPath.row] isEqualToString:@"snooze"]) {
        self.snoozeSwitch = [self settingsSwitch];
        cell.accessoryView = self.snoozeSwitch;
    }
    return cell;
}

#pragma mark - UIControl

- (UISwitch *)settingsSwitch
{
    UISwitch *theSwitch = [[UISwitch alloc] init];
    theSwitch.onTintColor = [UIColor redColor];
    theSwitch.backgroundColor = [UIColor grayColor];
    theSwitch.layer.cornerRadius = 16.0;
    [theSwitch addTarget:self
                  action:@selector(snoozeSwitchToggled:)
        forControlEvents:UIControlEventValueChanged];

    theSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"snoozeEnabled"];
    
    return theSwitch;
}

- (void)snoozeSwitchToggled:(id)sender
{
    NSLog(@"Switch State: %d", self.snoozeSwitch.on);
    [[NSUserDefaults standardUserDefaults] setBool:self.snoozeSwitch.on forKey:@"snoozeEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
