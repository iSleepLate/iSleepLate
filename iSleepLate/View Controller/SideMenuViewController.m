//
//  SideMenuViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/2/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MenuOptionTableViewCell.h"

@interface SideMenuViewController ()

@property (weak, nonatomic) IBOutlet UITableView *menuTable;
@property (strong, nonatomic) NSArray *menuItems;
@property (nonatomic) NSUInteger selectedRow;

@end

@implementation SideMenuViewController

#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.menuItems = @[@"alarm", @"settings", @"about"];
        self.selectedRow = 0;
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.menuTable.tableFooterView = [UIView new];
}

#pragma mark - Private Methods

- (UIView *)selectedRowOverlay
{
    return nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [self.menuItems objectAtIndex:indexPath.row];
    MenuOptionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == self.selectedRow) {
        cell.backgroundColor = [UIColor colorWithWhite:0.17 alpha:0.25];
        cell.selectionIndicator.hidden = NO;
    } else {
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionIndicator.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedRow == indexPath.row) {
        return;
    }
    
    self.selectedRow = indexPath.row;
    [tableView reloadData];
}

@end
